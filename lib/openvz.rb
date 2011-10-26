#
# OpenVZ API
#
module OpenVZ

    autoload :Log,         "openvz/log"
    autoload :Shell,       "openvz/shell"
    autoload :Inventory,   "openvz/inventory"
    autoload :Vendor,      "openvz/vendor"
    autoload :Container,   "openvz/container"
    autoload :Util,        "openvz/util"
    autoload :ConfigHash,  "openvz/confighash"

    VERSION = "1.2"
    
    def self.version
        VERSION
    end

    OpenVZ::Vendor.load_vendored
end
