module OpenVZ
    #
    # A simple class that allows logging at various levels.
    #
    class Log

        @known_levels = [:fatal, :error, :warn, :info, :debug]
        @active_level = :warn

        class << self
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

            # logs message at level
            def log(level, msg)
                if @known_levels.index(level) <= @known_levels.index(@active_level)
                    t = Time.new.strftime("%H:%M:%S")
                    STDERR.puts "#{t}: #{level}: #{from}: #{msg}"
                end
            end

            # Set the log level.
            def set_level(level)
                @active_level = level
            end

            # filename that called us
            def from
                from = File.basename(caller[2])
            end
        end
    end
end
