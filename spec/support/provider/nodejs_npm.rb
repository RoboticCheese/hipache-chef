# Encoding: UTF-8

class Chef
  class Provider
    # A fake nodejs_npm provider
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class NodejsNpm < Provider
      def load_current_resource
        @current_resource ||= Chef::Resource::NodejsNpm.new(
          new_resource.name
        )
      end
    end
  end
end
