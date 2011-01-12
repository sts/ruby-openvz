# == Ruby OpenVZ Library
#
# Framework to automate OpenVZ virtual machine administration.
#
#
module OpenVZ

    class OpenVZ

	require 'openvz/container'
	require 'openvz/vnode'
	require 'openvz/util'

    	VERSION = "1.0"
    	
    	def self.version
    	    VERSION
    	end
    end

end
