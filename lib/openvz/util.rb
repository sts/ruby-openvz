module OpenVZ
    class Util     
        # Generate a mac address based upon three different variables
        def generate_mac(ctid, vlanid, for_host)
            ctid_str     = '%06i' % ctid
            vlanid_str   = '%04i' % vlanid

            bridgemac    = [0,0,0,0,0,0]
            bridgemac[1] = ctid_str[0..1]
            bridgemac[2] = ctid_str[2..3]
            bridgemac[3] = ctid_str[4..5]
            bridgemac[4] = vlanid_str[0..1]
            bridgemac[5] = vlanid_str[2..3]
        
            if for_host
                bridgemac[0] = '12'
            else
                bridgemac[0] = '02'
            end
        
            # assemble macstring   
            '%s:%s:%s:%s:%s:%s' % bridgemac[0,6]
        end    

        # Search for a specific pattern and replace it with string
        # in file.
        def searchandreplace(file, pattern, replace)
            if File.writeable?(file)
                File.open(file, 'w') do |f|
                    $<.each_line do |line|
                        f.puts line.gsub(Regexp.new(pattern), replace)
                    end
                end
            else
                raise "File not writeable: #{file}."
            end
        end
        
        class << self
            # Class variable which denotes whether execute commands using sudo
            # should be true or false
            attr_accessor :enforce_sudo
        end
        
        # Execute a System Command
        def self.execute(cmd, params = {:cwd => "/tmp"})
            cmd = "sudo " + cmd if self.enforce_sudo 
          
            Log.debug("#{cmd}")
            
            s = Shell.new("#{cmd}", params)
            s.runcommand
            if s.status.exitstatus != 0
                raise "Cannot execute: '#{cmd}'. Return code: #{s.status.exitstatus}. Stderr: #{s.stderr}"
            end
            s.stdout
        end
    end
end
