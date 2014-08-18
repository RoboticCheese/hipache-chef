# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Recipe:: default
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

include_recipe 'nodejs'

hipache 'hipache' do
  [:version, :config_path, :driver, :config].each do |method|
    send(method, node['hipache'][method]) unless node['hipache'][method].nil?
  end

  [
    :access_log,
    :workers,
    :max_sockets,
    :dead_backend_ttl,
    :tcp_timeout,
    :retry_on_error,
    :dead_backend_on_500,
    :http_keep_alive
  ].each do |method|
    next unless node['hipache']['server'][method].nil?
    send(:"server_#{method}", node['hipache'][method])
  end

  [:port, :bind, :key, :cert].each do |method|
    next unless node['hipache']['https'][method]
    send(:"https_#{method}", node['hipache']['https'][method])
  end

  [:port, :bind].each do |method|
    next unless node['hipache']['http'][method]
    send(:"http_#{method}", node['hipache']['http'][method])
  end
end
