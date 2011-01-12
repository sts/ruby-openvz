# OpenVZ Ruby Library
#
# Usage:
#
#   ct = OpenVZ::Container.new("123")
#   ct.start
#   ct.stop
#   ct.restart
#   ct.create(template, :deboostrap => true)
#   ct.set( :hostname => "hmm.ono.at", :ip => '1.2.3.4'
#
#
#
#
module OpenVZ

    # Class: Container
    # 
    # Represents an OpenVZ Container.
    class Container

    require 'openvz/container/conf'
    require 'openvz/container/facts'

    attr_accessor :facts

    [:exist, :deleted, :mounted, :unmounted, :running, :down].each do |m|
        define_method(m) do
        return require_status m
        end
    end


    def initialize(ctid = false)
        @ctid = ctid
        raise ("You need to specify a container id (CTID) when creating this object.") unless @ctid

        @cmd_prefix = ['/usr/bin/sudo']
        @vzctl = [@cmd_prefix, '/usr/sbin/vzctl']

        # load the container configuration
        @configfile = "/etc/vz/conf/#{@ctid}.conf"
        @conf = Conf.new(@ctid)
        @conf.loadconfig(@configfile)
            
        @factsfile = "#{@conf.opt["VE_PRIVATE"]}/etc/facts.txt"
        @facts = Facts.new(@factsfile)

        # Util.new(container, true|false
        # true  -> execute
        # false -> just echo
        @util = Util.new(@ctid, false)
    end

    def status
        cmd = [@vzctl, 'status', @ctid]
        @util.execute(cmd).split(/\s/)
    end

    def require_status(*args)
        ret = true
        status = self.status()
    
        args.each do |opt|
            case opt
                when :exist
                    ret = (status[2] == "exist")
                when :deleted
                    ret = (status[2] == "deleted")
                when :mounted
                    ret = (status[3] == "mounted")
                when :unmounted
                    ret = (status[3] == "unmounted")
                when :running
                    ret = (status[4] == "running")
                when :down
                    ret = (status[4] == "down")
                else
                    raise("Unknown status passed to require_status")
            end
            return ret unless ret
        end
        return ret
    end


    # Start a container (puts it into running state) and returns a
    # boolean of whether the call succeeded or not.
    #
    # @return [Boolean]
    def start
        cmd = [@vzctl, 'start', @ctid]
        @util.execute(cmd) 
    end

    # Stop the container (puts it into a stopped state) and returns
    # a boolean of whether the call succeeded or not.
    #
    # @return [Boolean]
    def stop
        cmd = [@vzctl, 'stop', @ctid]
        @util.execute(cmd)
    end

    # Restarts a container (stops and starts it again) and returns
    # a boolean of whether the call succeeded or not.
    #
    # @return [Boolean]
    def restart
        cmd = [@vzctl, 'restart', @ctid]
            @util.execute(cmd)
    end

    # Sets all specified properties of a virtual machine and saves the
    # configuration The function takes a hash of symbols which are named
    # like vzctl set parameters.
    # Eg. vzctl set --hostname host.foo.bar is represented as 
    # set :hostname => "foo.bar.com".
    # Note: Currently the function doesn't check whether the options are
    # valid.
    #
    #
    # @return [Boolean]
    def set(options = {})
        options ||= {}

        # execute the set command
        cmd = []
            cmd << [ @vzctl, 'set',  @ctid, '--save']

        options.each do |opt,val|
         cmd << ["--#{opt}", val]
        end

        @util.execute(cmd)

        # reload the configuration
        @conf.loadconfig(@configfile)
    end

    # create a new container
        def create(options = {})
        options ||= {}

        deboostrap = false

        cmd = []
        cmd << [ @vzctl, 'create', @ctid ]

        options.each do |opt,val|
        case opt
            when :ostemplate
                cmd << ["--ostemplate=#{val}"]
            when :deboostrap
                deboostrap = true
                cmd << ["--ostemplate=debian-6.0-bootstrap"]
            when :config
                cmd << ["--config=#{val}"]
            end
        end

        @util.execute(cmd)

        @conf.loadconfig(@configfile)

        self.debootstrap(options[:deboostrap]) if deboostrap
    end

    # deboostrap a container
    # :mirror => "http://ftp.debian.org/debian"
    # :dist   => "squeeze"
    # :dest   => "/srv/vz/private/1234"
    def debootstrap(options = {})
        options ||= {}

        cmd = [@cmd_prefix, '/usr/sbin/debootstrap']
        cmd_append = []

        unless options[:dest]
        if @conf.opt.has_key?("VE_PRIVATE")
            options[:dest] = @conf.opt["VE_PRIVATE"]
        else
            raise("ERROR - Please specify the deboostrap destination. Neither config found nor was a :dest parameter supplied.")
        end
        end

        unless options[:dist] && options[:mirror]
        raise("ERROR - Please provide the following options to deboostrap(dist, mirror, [dest]).")
        end

        options.each do |opt,val|
        case opt
            when :mirror
            next
            when :dest
            next
            when :dist
            next
            else
            cmd << ["--#{opt} #{val}"]
        end
        end

        # debootstrap needs these arguments in this order
        cmd << [ options[:dist], options[:dest], options[:mirror]] 
        @util.execute(cmd)
    end

    # destroy a container
        def destroy
        cmd = [@vzctl, 'destroy', @ctid]
            @util.execute(cmd)
        end

    # copy a file into the container
    def cp_into(options = {})
        options ||= {}

        cmd = [@cmd_prefix, '/bin/cp', options[:src], "#{@conf.opt["VE_PRIVATE"]}/#{options[:dst]}"]
            @util.execute(cmd)
    end

    # execute a command inside the container
    def exec(command)
        cmd = [@vzctl, 'exec2', @ctid]

        if command.is_a? String
        cmd << [ command ]
        end

        output = @util.execute(cmd)

        puts output
    end

    end
end
