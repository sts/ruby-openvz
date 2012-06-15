module OpenVZ
    # OpenVZ::Container
    #
    # @author Stefan Schlesinger
    # @attribute rw config
    #
    # @example Sample Usage
    #   c = Container.new("999")
    #   c.start
    #   c.stop
    #   c.restart
    #   c.mount
    #   c.umount
    #   c.destroy
    #
    # @example Configration Access
    #   c = Container.new("999")
    #   puts c.config.privvmpages
    #   c.config.privvmpages = "123:123"
    #
    # @example Container Creation
    #   c = Container.new("999")
    #   c.create( :ostemplate => "debian-6.0-bootstrap", :config => "vps.unlimited" )
    #   c.debootstrap( :dist => "squeeze", :mirror => "http://ftp.at.debian.org" )
    #   c.cp_into(:src => "/etc/resolv.conf", :dest => "/etc/resolv.conf")
    #   c.start
    #   c.command("hostname -f")
    class Container

        attr_accessor :config
        attr_reader :ctid

        class StatemachineError < StandardError;end
        class Config            < ::OpenVZ::ConfigHash ; end


        def initialize(ctid=false)
            @ctid       = ctid
            @vzctl      = "/usr/sbin/vzctl"
            @vzmigrate  = "/usr/sbin/vzmigrate"
            @configfile = "/etc/vz/conf/#{ctid}.conf"

            @config     = Config.new(load_config_file)
            @config.add_observer(self)
        end


        # Start a container
        #
        def start
            cmd = "#{@vzctl} start #{@ctid}"
            execute(cmd)
        end


        # Stop a container
        #
        def stop
            cmd = "#{@vzctl} stop #{@ctid}"
            execute(cmd)
        end


        # Restart a container
        #
        def restart
            cmd = "#{@vzctl} restart #{@ctid}"
            execute(cmd)
        end


        # Mount a container
        #
        def mount
            cmd = "#{@vzctl} mount #{@ctid}"
            execute(cmd)
        end


        # Umount a container
        #
        def umount
            cmd = "#{@vzctl} umount #{@ctid}"
            execute(cmd)
        end


        # Destroy a container
        #
        def destroy
            cmd = "#{@vzctl} destroy #{@ctid}"
            execute(cmd)
        end


        # Checkpoint the container
        #
        def checkpoint(snapshot_path)
            cmd = "#{@vzctl} chkpnt #{@ctid} --dumpfile #{snapshot_path}"
            execute(cmd)
        end


        # Restore a checkpoint
        #
        def restore(snapshot_path)
            cmd = "#{@vzctl} restore #{@ctid} --dumpfile #{snapshot_path}"
            execute(cmd)
        end
        
        # Migrate container to another node
        #
        def migrate(destination_address, options=%w(--remove-area yes --online --rsync=-az))
            cmd = "#{@vzmigrate} #{options.join ' '} #{destination_address} #{@ctid}"
            execute(cmd)
        end


        # Update one or multiple Container properties and keep the configration
        # object up to date
        #
        # @param [Hash] The options to update, eg. `{ :privvmpages => '123:123' }`
        def set(options = {})
            # Construct a set command
            cmd = "#{@vzctl} set #{@ctid} --save"
    
            options.each do |opt,val|
                cmd << " --#{opt}"
                cmd << " #{val}"
            end

            execute(cmd)

            # Each time we update a setting, reload the configuration.
            @config.load(@ctid)
        end


        # Create a new empty instance from a template.
        #
        # @example Create a new empty container from a template.
        #   The following example will create a container, from an empty
        #   template, which can be used to bootstrap the whole installation
        #   later on. It will as well apply the vps.unlimited template config.
        #
        #   container.create(:ostemplate => "debian-6.0-bootstrap", :config => "vps.unlimited")
        #
        # @param [Hash] options you want to pass to the create statement.
        def create(options={})
            unless options[:ostemplate]
                # We need at least a valid ostemplate
                raise ArgumentError, "Create requires argument :ostemplate."
            end

            cmd = "#{@vzctl} create #{@ctid}"

            options.each do |opt,val|
                cmd << " --#{opt}"
                cmd << " #{val}"
            end

            execute(cmd)

            Log.debug("Reading new container configuration file: #{@configfile}")
            @config     = Config.new(load_config_file)
            @config.add_observer(self)
        end


        # Bootstrap a Debian container, this requires /usr/sbin/debootstrap to
        # be installed. Executing this function usually takes a while.
        #
        # @example Debootstrap a container object.
        #   container.debootstrap(:dist => "squeeze", :mirror => "http://cdn.debian.net/debian")
        #
        # @example Debootstrap a container, include and exclude certain packages.
        #   container.debootstrap(
        #       :dist    => "squeeze",
        #       :mirror  => "http://cdn.debian.net/debian",
        #       :include => "libreadline6,screen,file,less,dnsutils,tcpdump,vim-nox,puppet,facter",
        #       :exclude => "dhcp-client,dhcp3-client,dhcp3-common,dmidecode,gcc-4.2-base,module-init-tools,tasksel,tasksel-data,libdb4.4,libsasl2-2,libgnutls26,libconsole,libgnutls13,libtasn1-3,liblzo2-2,libopencdk10,libgcrypt11",
        #   )
        #
        # @param [Hash] options you want to pass to the bootstrapping tool.
        def debootstrap(options={})
            cmd  = "/usr/sbin/debootstrap"

            options.each do |opt,val|
                unless opt.to_s =~ /dist|dest|mirror/
                    cmd << " --#{opt} #{val}"
                end
            end

            cmd << " #{options[:dist]}"
            cmd << " #{@config.ve_private}"
            cmd << " #{options[:mirror]}"

            execute(cmd)

            # FIXME - Remove gettys from inititab automatically. We
            # Need a searchandreplace function first... :-)
            #
            # Util.searchandreplace( "#{@config.ve_private}/etc/inittab",
            #                        "/^(?!#)(.*\/sbin\/getty)/", 
            #                        '#\1')
        end


        # Copy a file from the hardware node into the container.
        #
        # @example Copy resolv.conf
        #     container.cp_into(
        #          :src => '/etc/resolv.conf',
        #          :dst => '/etc/resolv.conf'
        #     )
        #
        # @param [Hash] define
        def cp_into(options={})
            cmd = "/bin/cp #{options[:src]} #{@config.ve_private}/#{options[:dst]}"
            execute(cmd)
        end


        # Run a shell command within the container.
        #
        # @example Update the package sources.
        #    container.command("aptitude update")
        #
        # @param [String] Command to be executed.
        def command(command)
            cmd = "#{@vzctl} exec2 #{@ctid} "
            cmd << command
            execute(cmd)
        end


        # Return the current machine status string.
        # 
        # @example
        #   puts container.status()
        #   exist mounted running
        def status
            cmd = "#{@vzctl} status #{@ctid}"
            status = execute(cmd).split(/\s/)
            Log.debug("Container (#{@ctid}) status requested: #{status}")
            status.drop(2)
        end


        # Return the current uptime in seconds.
        # Return zero if the container is not running.
        #
        # @example
        #   puts container.uptime()
        #   1188829
        def uptime
          return 0 unless status.include? "running"
          raw = command "cat /proc/uptime"
          Log.debug("Container (#{@ctid}) uptime requested: #{raw}")
          raw.split(/\W/).first.to_i
        end


        ####
        #### Helper methods
        ####


        def state_require(*opts)
            current_state = status
            if current_state & opts
                puts "req: #{opts.join("-")}, cur: #{current_state.join("-")}"
                return true
            else
              raise StateMachineError, "Required container status not met for this action. req: #{opts.join("-")}, cur: #{current_state.join("-")}"
            end
        end


        # Check whether current_state == :require||:validate
        #
        def state(mode, action)
            current_state = self.status()

            if current_state & @statemachine_options[action.to_sym][mode.to_sym]
                return true
            end

            raise StateMachineError,
               "Required container status not met. req: #{@state_control[:action]}, cur: #{state}"
        end


        # Notify Method! :-) Config objects will notify, as soon as they are changed.
        #
        def update(key, value)
            set(key.to_sym => value)
        end


        # Load the container configration file.
        #
        def load_config_file
            data = {}
            if File.exists?(@configfile)
                File.open(@configfile, "r").each_line do |line|
                    # strip blank spaces, tabs etc. off the lines
                    line.gsub!(/\s*$/, "")
        
                    if (line =~ /^([^=]+)="([^=]*)"$/)
                        key = $1.downcase
                        val = $2
        
                        case key
                            when /^ve_(private|root)$/
                                data[key] = val.gsub!(/\$VEID/, @ctid)
                            else
                                data[key] = val
                        end
                    end
                end
            end
            data
        end


        # TODO: implement :-)
        #
        # NETIF="ifname=eth0,
        #        bridge=vzbr303,
        #        mac=02:01:79:15:03:02,
        #        host_ifname=veth17915.303,
        #        host_mac=12:01:79:15:03:02"
        #def load_net_config
        #    if @config.netif ### DOES THAT WORK?
        #        str = @config.netif

        #        if str =~ /ifname=([^,]+),bridge=([^,]+),mac=([^,]+),host_ifname=([^,]+),host_mac=([^,]+)/
        #            @net.ifname      = $1
        #            @net.bridge      = $2
        #            @net.mac         = $3
        #            @net.host_ifname = $4
        #            @net.host_mac    = $5
        #            @net.type        = "bridged"
        #            ### MISSING: IP, SUBNET, GATEWAY within VM
        #        end
        #    end
        #end

        # This will give us a nicer object feeling and dynamically
        # exposes variables to the outside.
        #
        # @examples Setting and getting a variable
        # container.config.ipaddress = 1.2.3.4
        #
        #
        #def method_missing(sym, *args)
        #  if sym.to_s =~ /(.+)=$/
        #    self[$1] = args.first
        #  else
        #    self[sym]
        #  end
        #end


        # Execute a System Command
        def execute(cmd)
            Util.execute(cmd)
        end
    end
end
