# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Library:: provider/hipache_npm
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

require 'json'
require 'chef/provider'
require 'chef/resource/file'
require 'chef/resource/service'
require 'chef/resource/template'
require_relative 'hipache_helpers'
require_relative 'resource_hipache'

class Chef
  class Provider
    class Hipache < Provider
      # A Chef provider for the Hipache NPM package
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Npm < Provider
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
          init_script.run_action(:create)
          config_dir.run_action(:create)
          config.run_action(:create)
        end

        #
        # Uninstall the Hipache package
        #
        def action_uninstall
          [:stop, :disable].each { |a| service.run_action(a) }
          config.run_action(:delete)
          config_dir.only_if do
            ::Dir.new(path).entries.delete_if do |i|
              %w(. ..).include?(i)
            end.length == 0
          end
          config_dir.run_action(:delete)
          init_script.run_action(:delete)
          package.run_action(:uninstall)
        end

        #
        # Define enable/disable/start/stop Hipache service actions
        #
        [:enable, :disable, :start, :stop].each do |act|
          define_method(:"action_#{act}") { service.run_action(act) }
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

        #
        # The Hipache service resource
        #
        # @return [Chef::Resource::Service]
        #
        def service
          @service ||= Resource::Service.new(app_name, run_context)
          @service.provider(Provider::Service.const_get(init_system.capitalize))
          @service
        end

        #
        # A init script template resource
        #
        # @return [Chef::Resource::Template]
        #
        def init_script
          unless init_system == :upstart
            fail(::Hipache::Exceptions::UnsupportedPlatform, :init_script)
          end
          @init_script ||= Resource::Template.new("/etc/init/#{app_name}.conf",
                                                  run_context)
          @init_script.cookbook(cookbook_name.to_s)
          @init_script.source("init/#{init_system}.erb")
          @init_script.variables(executable: app_name,
                                 conf_file: new_resource.config_path)
          @init_script
        end

        #
        # The config file resource
        #
        # @return[Chef::Resource::File]
        #
        def config
          @config ||= Resource::File.new(new_resource.config_path,
                                         run_context)
          # TODO: Add a "DO NOT EDIT" header + generate readable JSON
          @config.content(JSON.dump(generate_config_hash))
          @config
        end

        #
        # A resource for the directory in which the config is located
        #
        # @return[Chef::Resource::Directory]
        #
        def config_dir
          @config_dir ||= Resource::Directory.new(
            ::File.dirname(new_resource.config_path), run_context
          )
          @config_dir.recursive(true)
          @config_dir
        end

        #
        # Generate a config hash based on the new_resource
        #
        # @return [Hash]
        #
        def generate_config_hash
          # TODO: This won't translate the key names to camel case; is that
          # a problem?
          return new_resource.config if new_resource.config
          generate_top_level_hash.merge(
            server: generate_server_hash,
            https: generate_https_hash,
            http: generate_http_hash
          )
        end

        # Generate everything at the top level of a Hipache config
        #
        # @return [Hash]
        #
        def generate_top_level_hash
          VALID_OPTIONS.each_with_object({}) do |(k, v), hsh|
            next if [:server, :http, :https].include?(k)
            hsh[v[:alt_name]] = new_resource.send(k)
          end
        end

        #
        # Generate just the hash of server options
        #
        # @return [Hash]
        #
        def generate_server_hash
          VALID_OPTIONS[:server].each_with_object({}) do |(k, v), hsh|
            hsh[v[:alt_name]] = new_resource.send(:"server_#{k}")
          end
        end

        #
        # Generate just the hash of https options
        #
        # @return [Hash]
        #
        def generate_https_hash
          VALID_OPTIONS[:https].each_with_object({}) do |(k, v), hsh|
            hsh[v[:alt_name]] = new_resource.send(:"https_#{k}")
          end
        end

        #
        # Generate just the hash of http options
        #
        # @return [Hash]
        #
        def generate_http_hash
          VALID_OPTIONS[:http].each_with_object({}) do |(k, v), hsh|
            hsh[v[:alt_name]] = new_resource.send(:"http_#{k}")
          end
        end
      end
    end
  end
end
