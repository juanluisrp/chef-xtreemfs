#
# Cookbook Name:: xtreemfs
# Recipe:: default
#
# Copyright (C) 2013 Cloudbau GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

include_recipe "apt"

include_recipe "chef-solo-search" if Chef::Config[:solo]

apt_repository "xtreemfs" do
  uri "http://download.opensuse.org/repositories/home:/xtreemfs/xUbuntu_#{node['lsb']['release']}"
  key "http://download.opensuse.org/repositories/home:/xtreemfs/xUbuntu_#{node['lsb']['release']}/Release.key"
  distribution "./"
  action :add
end

package "xtreemfs-server"
