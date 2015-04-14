# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Library:: provider_hipache_service
#
# Copyright 2014-2015, Jonathan Hartman
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
require 'chef/resource/service'
require 'chef/resource/template'
require_relative 'hipache_helpers'
require_relative 'resource_hipache_service'

class Chef
  class Provider
    # A Chef provider for the Hipache service
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class HipacheService < Provider
      include ::Hipache::Helpers

      #
      # Advertise WhyRun mode support
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      #
      # Load and return the current resource
      #
      # @return [Chef::Resource::HipacheService]
      #
      def load_current_resource
        @current_resource ||= Resource::HipacheService.new(new_resource.name,
                                                           run_context)
      end

      #
      # Create the service config file
      #
      def action_create
        config_file.run_action(:create)
        new_resource.created = true
      end

      #
      # Delete the service config file
      #
      def action_delete
        config_file.run_action(:delete)
        new_resource.created = false
      end

      # Send enable/disable/start/stop actions to the wrapped service resource
      {
        enable: [:enabled, true],
        disable: [:enabled, false],
        start: [:running, true],
        stop: [:running, false]
      }.each do |action, (state, status)|
        define_method(:"action_#{action}") do
          service.run_action(action)
          new_resource.send(:"#{state}=", status)
        end
      end

      private

      #
      # A Chef Service resource for Hipache
      #
      # @return [Chef::Resource::Service]
      #
      def service
        @service ||= Resource::Service.new(app_name, run_context)
        @service.provider(
          Provider::Service.const_get(new_resource.init_system.capitalize)
        )
        @service
      end

      #
      # A Template resource for the service config file/script
      #
      # @return [Chef::Resource::Template]
      #
      def config_file
        @config_file ||= Resource::Template.new("/etc/init/#{app_name}.conf",
                                                run_context)
        @config_file.cookbook(cookbook_name.to_s)
        @config_file.source('init/upstart.erb')
        @config_file.variables(executable: app_name,
                               conf_file: new_resource.config_path)
        @config_file
      end
    end
  end
end
