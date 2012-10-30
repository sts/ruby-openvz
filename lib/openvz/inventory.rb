module OpenVZ
    class Inventory < ConfigHash
        def initialize()
          @vzlist = "/usr/sbin/vzlist"
        end
      
        def load
            Util.execute("#{@vzlist} -a").each_line { |l|
                # inventarize a container object for each avaiable container.
                if l =~ /^\s+(\d+)\s+(.*)\s+(running|stopped)\s+(.*)\s\s(.*)$/
                    self[$1] = Container.new($1)
                end
            }
        end
        
        # Returns cotainers' id as a array of strings
        def ids
            Util.execute("#{@vzlist} -a1").split
        end

        def to_hash
            @data
        end
    end
end