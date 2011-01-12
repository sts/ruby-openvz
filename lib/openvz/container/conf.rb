module OpenVZ

    class Conf

	attr_reader :opt, :configured

	def initialize(ctid = false)
	    @ctid = ctid
	    raise ("Please specify the container id (CTID) when initializing the Conf object.") unless @ctid
	    @configured = false
    	end

	def loadconfig(configfile)
	    @opt = {}

            if File.exists?(configfile)
		File.open(configfile, "r").each_line do |line|

		    # strip blank spaces, tabs etc. off the lines
		    line.gsub!(/\s*$/, "")

		    unless line =~ /^#|^$/
			if (line =~ /^([^=]+)="([^=]*)"$/)
			    key = $1
			    val = $2

			    case key
				when /^VE_(PRIVATE|ROOT)$/
				    @opt[key] = val.gsub!(/\$VEID/, @ctid)
				else
				    @opt[key] = val
			    end
                            ## TODO - do this for "val":
			    ##when /^([0-9]+)\:([0-9]+)/
			    ##    @opt[key] = [$1, $2] 
			end
		    end
	    
		    @configured = true
		end
	    end
        end
    end
end
