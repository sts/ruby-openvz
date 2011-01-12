module OpenVZ

    # Class: VNode
    # 
    # Represents an OpenVZ Hardware Node.
    class VNode

	def load_container_list
	    filename = "/proc/vz/veinfo"

	    if File.exist?(filename)
		File.open(filename, "r").each_line do |line|
		    line.strip!
		    array = line.split(/ +/)[0]
		    return array
		end
	    else
		return nil
	    end
	end

    end
end
