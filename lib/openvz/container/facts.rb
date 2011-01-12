class Facts

    def initialize(factsfile)
        @facts     = {}
        @factsfile = factsfile

        self.load
    end

    def [](key)
       @facts[key]
    end

    def []=(key,val)
       @facts[key]=val
       self.commit
       self.load
    end

    def load
        if File.exists?(@factsfile)
            File.open(@factsfile, "r").each_line do |line|
                if line =~ /^(.+)=(.+)$/
                        key = $1 ; val = $2
                        @facts[key] = val
                end
            end
        end
        @loaded = 1
    end

    def commit
        raise StandardError, "Please load the facts before you commit them." unless @loaded

        File.open(@factsfile, "w") do |file|
            file.flock(File::LOCK_EX)

            @facts.each do |k,v|
                file.puts "#{k}=#{v}\n"
            end
        end
    end
end

