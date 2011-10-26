module OpenVZ
    # A simple class that allows logging at various levels.
    class Log
        class << self
            @logger = nil

            # Obtain the class name of the currently configured logger
            def logger
                @logger.class
            end

            # Logs at info level
            def info(msg)
                log(:info, msg)
            end

            # Logs at warn level
            def warn(msg)
                log(:warn, msg)
            end

            # Logs at debug level
            def debug(msg)
                log(:debug, msg)
            end

            # Logs at fatal level
            def fatal(msg)
                log(:fatal, msg)
            end

            # Logs at error level
            def error(msg)
                log(:error, msg)
            end

            # handle old code that relied on this class being a singleton
            def instance
                self
            end

            # increments the active log level
            def cycle_level
                @logger.cycle_level if @configured
            end

            # logs a message at a certain level
            def log(level, msg)
                t = Time.new.strftime("%H:%M:%S")
                STDERR.puts "#{t}: #{level}: #{from}: #{msg}"
            end

            # sets the logger class to use
            def set_logger(logger)
                @logger = logger
            end


            # figures out the filename that called us
            def from
                from = File.basename(caller[2])
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai:filetype=ruby
