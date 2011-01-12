module OpenVZ

    class Util

    def initialize(ctid, dont_execute_cmds = nil)
        @ctid  = ctid
        @dont_execute_cmds = dont_execute_cmds

        unless @ctid
            return nil
        end
    end

    # Borrowed from puppet util
    def execute(command)
        require "tempfile"

        if command.is_a?(Array)
             command = command.flatten.collect { |i| i.to_s }
             str     = command.join(" ")
        else
             raise ArgumentError, "Must pass an array to execute()"
        end

        puts "Executing '%s'" % str

        if @dont_execute_cmds
            return true
        end

        output_file = Tempfile.new("mcollective-openvz-agent.out")
        error_file  = Tempfile.new("mcollective-openvz-agent.err")
        stdin_file  = "/dev/null"

        child_pid = Kernel.fork
        
        if child_pid
            child_status = (Process.waitpid2(child_pid)[1]).to_i >> 8
        else
            # Child process executes this
            Process.setsid
            begin
                $stdin.reopen(stdin_file)
                $stdout.reopen(output_file)
                $stderr.reopen(error_file)

                3.upto(256){|fd| IO::new(fd).close rescue nil}

                ENV['LANG'] = ENV['LC_ALL'] = ENV['LC_MESSAGES'] = ENV['LANGUAGE'] = 'C'

                if command.is_a?(Array)
                    Kernel.exec(*command)
                else
                    Kernel.exec(command)
                end
                
                rescue => detail
                    puts detail.to_s
                    exit!(222)
                end
            end

            unless FileTest.exists?(output_file.path)
                puts "sleeping"
                sleep 0.5
                unless FileTest.exists?(output_file.path)
                    puts "sleeping 2"
                    sleep 1
                    unless FileTest.exists?(output_file.path)
                        puts "Warning: could not get output"
                        output = ""
                    end
                end
            end

            unless output
                output = output_file.open.read
                output_file.close(true)
            end

            unless child_status == 0
                raise "\n\nCommand: #{command}\nExecution failed with return code: #{child_status}\nOutput:\n  #{output}\n\n"
            end

            output
        end
    end
end
