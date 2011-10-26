require 'observer'

module OpenVZ

    class ConfigHash

        include Observable

        def initialize(data={})
          @data = {}
          update!(data)
        end
        
        def update!(data)
          data.each do |key, value|
            self[key] = value
          end
        end
        
        def [](key)
          @data[key.to_sym]
        end
        
        def []=(key, value)
            if @data[key] != value
                if value.class == Hash
                  @data[key.to_sym] = Config.new(value)
                else
                  @data[key.to_sym] = value
                end
                # Notify observers
                changed
                notify_observers(key, value)
            end
        end
        
        def method_missing(sym, *args)
          if sym.to_s =~ /(.+)=$/
            self[$1] = args.first
          else
            self[sym]
          end
        end
    end
end
