module OpenVZ
    class Inventory < ConfigHash
        def load
            s = Shell.new("/usr/sbin/vzlist -a", :cwd => "/tmp")
            s.runcommand

            ret_code = s.status
            if ret_code != 0
                raise StandardError, "Execution of shell command failed. Command: #{s.command} RC: #{ret_code} Error: #{s.stderr}\n\n"
            end

            s.stdout.each { |l|
                # inventarize a container object for each avaiable container.
                if l =~ /^\s+(\d+)\s+(.*)\s+(running|stopped)\s+(.*)\s\s(.*)$/
                    self[$1] = Container.new($1)
                end
            }
        end

        def to_hash
            @data
        end
    end
end
