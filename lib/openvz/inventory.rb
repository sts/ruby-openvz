module OpenVZ
    class Inventory < ConfigHash
        VZLIST = "sudo /usr/sbin/vzlist"
      
        def load
            Util.execute("#{VZLIST} -a").each { |l|
                # inventarize a container object for each avaiable container.
                if l =~ /^\s+(\d+)\s+(.*)\s+(running|stopped)\s+(.*)\s\s(.*)$/
                    self[$1] = Container.new($1)
                end
            }
        end
        
        # Returns cotainers' id as a array of strings
        def ids
            Util.execute("#{VZLIST} -a1").split
        end

        def to_hash
            @data
        end
    end
end