#
# Cookbook Name:: xtreemfs
# Recipe:: dir
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

if node[:xtreemfs][:dir][:uuid].nil?
  node.set[:xtreemfs][:dir][:uuid] = `uuidgen`
end

template "/etc/xos/xtreemfs/dirconfig.properties" do
  source "dirconfig.properties.erb"
  mode 0440
  owner node[:xtreemfs][:user]
  group node[:xtreemfs][:group]
  variables({
     :uuid => node[:xtreemfs][:dir][:uuid],
     :ip_address => node[:xtreemfs][:dir][:bind_ip],
     :listen_port => node[:xtreemfs][:dir][:listen_port],
     :http_port => node[:xtreemfs][:dir][:http_port],
     :debug_level => 4, # 0 .. 7 ~ emergency .. debug
     :babudb_debug_level => 4,
     :replication => node[:xtreemfs][:dir][:replication]
  })
  notifies :reload, 'service[xtreemfs-dir]', :delayed
end

if node[:xtreemfs][:dir][:replication]
  dir_service_hosts = get_service_hosts('dir')

  template '/etc/xos/xtreemfs/server-repl-plugin/dir.properties' do
    source "repl.properties.erb"
    mode 0440
    owner node[:xtreemfs][:user]
    group node[:xtreemfs][:group]
    variables({
      :service => 'DIR',
      :repl_participants => dir_service_hosts,
      :babudb_repl_sync_n => (dir_service_hosts.length/2.0).ceil
    })
    notifies :reload, 'service[xtreemfs-dir]', :delayed
  end
end

service "xtreemfs-dir" do
  action [ :enable, :start ]
end

node.set[:xtreemfs][:dir][:service] = true
node.save
