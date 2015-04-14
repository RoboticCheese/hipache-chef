# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Library:: provider_hipache_configuration
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

require 'json'
require 'chef/provider'
require 'chef/resource/file'
require_relative 'hipache_helpers'
require_relative 'resource_hipache_configuration'

class Chef
  class Provider
    # A Chef provider for a Hipache configuration
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class HipacheConfiguration < Provider
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
      # @return [Chef::Resource::HipacheConfiguration]
      #
      def load_current_resource
        @current_resource ||= Resource::HipacheConfiguration.new(
          new_resource.name
        )
      end

      #
      # Install the Hipache config file
      #
      def action_create
        config_dir.run_action(:create)
        config_file.run_action(:create)
        new_resource.created = true
      end

      #
      # Delete the Hipache config file
      #
      def action_delete
        config_file.run_action(:delete)
        config_dir.only_if do
          ::Dir.new(path).entries.delete_if do |i|
            %w(. ..).include?(i)
          end.length == 0
        end
        config_dir.run_action(:delete)
        new_resource.created = false
      end

      private

      #
      # The config file resource
      #
      # @return[Chef::Resource::File]
      #
      def config_file
        @config_file ||= Resource::File.new(new_resource.path,
                                            run_context)
        # TODO: Add a "DO NOT EDIT" header + generate readable JSON
        @config_file.content(JSON.dump(generate_config_hash))
        @config_file
      end

      #
      # A resource for the directory in which the config is located
      #
      # @return[Chef::Resource::Directory]
      #
      def config_dir
        @config_dir ||= Resource::Directory.new(
          ::File.dirname(new_resource.path), run_context
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
        return new_resource.config_hash if new_resource.config_hash
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
