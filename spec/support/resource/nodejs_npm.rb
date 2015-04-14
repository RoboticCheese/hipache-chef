# Encoding: UTF-8

class Chef
  class Resource
    # A fake nodejs_npm resource
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class NodejsNpm < Resource
      def initialize(name, run_context = nil)
        super
        @resource_name = :nodejs_npm
        @action = :install
        @allowed_actions = [:install, :uninstall]
      end

      def version(arg = nil)
        set_or_return(:version, arg, kind_of: String)
      end
    end
  end
end
