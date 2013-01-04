#
# OpenVZ API
#
module OpenVZ
    autoload :Log,         "openvz/log"
    autoload :Shell,       "openvz/shell"
    autoload :Inventory,   "openvz/inventory"
    autoload :Container,   "openvz/container"
    autoload :Util,        "openvz/util"
    autoload :ConfigHash,  "openvz/confighash"

    VERSION = "1.5.5"
    
    def self.version
        VERSION
    end
end
