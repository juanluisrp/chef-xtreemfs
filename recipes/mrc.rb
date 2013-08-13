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

if node[:xtreemfs][:mrc][:uuid].nil?
  node.set[:xtreemfs][:mrc][:uuid] = `uuidgen`
end

dir_service_hosts = get_service_hosts('dir')

template "/etc/xos/xtreemfs/mrcconfig.properties" do
  source "mrcconfig.properties.erb"
  mode 0440
  owner node[:xtreemfs][:user]
  group node[:xtreemfs][:group]
  variables({
     :dir_service_hosts => dir_service_hosts,
     :uuid => node[:xtreemfs][:mrc][:uuid],
     :ip_address => node[:xtreemfs][:mrc][:bind_ip],
     :listen_port => node[:xtreemfs][:mrc][:listen_port],
     :http_port => node[:xtreemfs][:mrc][:http_port],
     :debug_level => 4, # 0 .. 7 ~ emergency .. debug
     :babudb_debug_level => 4,
     :replication => node[:xtreemfs][:mrc][:replication],
     :babudb_sync => node[:xtreemfs][:mrc][:replication] ? 'FDATASYNC' : 'ASYNC'
  })
  notifies :reload, 'service[xtreemfs-mrc]', :delayed
end

if node[:xtreemfs][:mrc][:replication]
  mrc_repl_participants = get_service_hosts('mrc')

  template '/etc/xos/xtreemfs/server-repl-plugin/mrc.properties' do
    source "repl.properties.erb"
    mode 0440
    owner node[:xtreemfs][:user]
    group node[:xtreemfs][:group]
    variables({
      :service => 'MRC',
      :repl_port => node[:xtreemfs][:mrc][:repl_port],
      :repl_participants => mrc_repl_participants,
      :babudb_repl_sync_n => (mrc_repl_participants.length/2.0).ceil # TODO do something more clever here
    })
    notifies :reload, 'service[xtreemfs-mrc]', :delayed
  end
end


service "xtreemfs-mrc" do
  action [ :enable, :start ]
end

node.set[:xtreemfs][:mrc][:service] = true
#node.save
