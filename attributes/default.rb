# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Attributes:: default
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

default['hipache']['version'] = nil
default['hipache']['config_path'] = nil

default['hipache']['server']['access_log'] = nil
default['hipache']['server']['workers'] = nil
default['hipache']['server']['max_sockets'] = nil
default['hipache']['server']['dead_backend_ttl'] = nil
default['hipache']['server']['tcp_timeout'] = nil
default['hipache']['server']['retry_on_error'] = nil
default['hipache']['server']['dead_backend_on_500'] = nil
default['hipache']['server']['http_keep_alive'] = nil

default['hipache']['https']['port'] = nil
default['hipache']['https']['bind'] = nil
default['hipache']['https']['key'] = nil
default['hipache']['https']['cert'] = nil

default['hipache']['http']['port'] = nil
default['hipache']['http']['bind'] = nil

default['hipache']['driver'] = nil

default['hipache']['config_hash'] = nil
