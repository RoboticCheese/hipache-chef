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
require_relative 'resource_hipache'

class Chef
  class Provider
    # A Chef provider for the Hipache Node.js package
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Hipache < Provider
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
        fail 'Not yet implemented'
      end

      #
      # Install the Hipache package
      #
      def action_install
        fail 'Not yet implemented'
      end

      #
      # Uninstall the Hipache package
      #
      def action_uninstall
        fail 'Not yet implemented'
      end
    end
  end
end
