#
# Cookbook Name:: xtreemfs
# Recipe:: mrc
#
# Copyright (C) 2013 cloudbau GmbH
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

include_recipe "xtreemfs::default"

package "xtreemfs-server"

if node[:xtreemfs][:mrc][:uuid].nil?
  node.set[:xtreemfs][:mrc][:uuid] = `uuidgen`
end

# TODO: Support multiple dir_services
if Chef::Config[:solo]
  dir_service_host = node[:xtreemfs][:dir][:bind_ip]
else
  dir_service_host = search(:node, 'xtreemfs_dir_service:true').map {|n| n[:xtreemfs][:dir][:bind_ip]}.first
end

template "/etc/xos/xtreemfs/mrcconfig.properties" do
  source "mrcconfig.properties.erb"
  mode 0440
  owner node[:xtreemfs][:user]
  group node[:xtreemfs][:group]
  variables({
     :dir_service_host => dir_service_host,
     :uuid => node[:xtreemfs][:mrc][:uuid],
     :ip_address => node[:xtreemfs][:mrc][:bind_ip]
  })
end

service "xtreemfs-mrc" do
  action [ :enable, :start ]
end

node.set[:xtreemfs][:mrc][:service] = true
