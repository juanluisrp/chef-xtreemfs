#
# Cookbook Name:: xtreemfs
# Recipe:: osd
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

package "xtreemfs-server" do
  action :upgrade
end

dir_service_hosts = get_service_hosts('dir')

0.upto(node[:xtreemfs][:osd][:count]) do |osd_number|
  template "/etc/xos/xtreemfs/osdconfig.#{osd_number}.properties" do
    osd_id = :"osd#{osd_number}_uuid"
    if node[:xtreemfs][:osd][osd_id].nil?
      node.set[:xtreemfs][:osd][osd_id] = `uuidgen`
    end
    source "osdconfig.properties.erb"
    mode 0440
    owner node[:xtreemfs][:user]
    group node[:xtreemfs][:group]
    variables({
      :dir_service_hosts => dir_service_hosts,
      :object_directory => File.join(node[:xtreemfs][:osd][:object_base_directory], osd_number.to_s),
      :listen_port => (node[:xtreemfs][:osd][:first_listen_port] + osd_number),
      :http_port => (node[:xtreemfs][:osd][:first_http_port] + osd_number),
      :uuid => node[:xtreemfs][:osd][osd_id],
      :listen_address => node[:xtreemfs][:osd][:bind_ip]
    })
    notifies :restart, "service[xtreemfs-osd.#{osd_number}]", :immediately
  end

  template "/etc/init/xtreemfs-osd.#{osd_number}.conf" do
    source "upstart.conf.erb"
    variables({
      :descr => "XtreemFS OSD number #{osd_number}",
      :class => 'org.xtreemfs.osd.OSD',
      :config => "/etc/xos/xtreemfs/osdconfig.#{osd_number}.properties",
      :user => node[:xtreemfs][:user],
      :group => node[:xtreemfs][:group],
      :start_on => 'started xtreemfs-osd-all',
      :stop_on => 'stopped xtreemfs-osd-all'
    })
  end

  service "xtreemfs-osd.#{osd_number}" do
    provider Chef::Provider::Service::Upstart
    action [ :enable, :start ]
  end
    
  link "/var/log/xtreemfs/osd.#{osd_number}.log" do
    to "/var/log/upstart/xtreemfs-osd.#{osd_number}.log"
  end

  link "/etc/init.d/xtreemfs-osd.#{osd_number}" do
    to '/lib/init/upstart-job' 
  end
end

template "/etc/init/xtreemfs-osd-all.conf" do
  source 'xtreemfs-osd-all.conf.erb'
  variables({
    :user => node[:xtreemfs][:user],
    :group => node[:xtreemfs][:group],
    :start_on => 'stopped networking',
    :stop_on => 'deconfiguring-networking'
  })
end

service "xtreemfs-osd-all" do
  provider Chef::Provider::Service::Upstart
  action :enable
end

