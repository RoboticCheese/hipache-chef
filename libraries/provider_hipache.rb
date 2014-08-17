# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Library:: provider/hipache
#
# Copyright 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider'
require 'chef/resource/template'
require_relative 'hipache_helpers'
require_relative 'resource_hipache'

class Chef
  class Provider
    # A Chef provider for the Hipache Node.js package
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Hipache < Provider
      include ::Hipache::Helpers

      #
      # WhyRun is supported by this provider
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      #
      # Load and return the current resource
      #
      # @return [Chef::Resource::Hipache]
      #
      def load_current_resource
        @current_resource ||= Resource::Hipache.new(new_resource.name)
      end

      #
      # Install the Hipache package
      #
      def action_install
        package.run_action(:install)
      end

      #
      # Uninstall the Hipache package
      #
      def action_uninstall
        package.run_action(:uninstall)
      end

      private

      #
      # The NPM package resource for the Hipache application
      #
      # @return [Chef::Resource::NodejsNpm]
      #
      def package
        @package ||= Resource::NodejsNpm.new(app_name, run_context)
        unless new_resource.version == 'latest'
          @package.version(new_resource.version)
        end
        @package
      end
    end
  end
end
