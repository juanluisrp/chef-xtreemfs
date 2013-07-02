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

package "xtreemfs-server"

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
  end

  service_file = "/etc/init.d/xtreemfs-osd.#{osd_number}"
  
  script "create service for OSD #{osd_number}" do
    interpreter "bash"
    user "root"
    cwd "/tmp"
    code "cp /etc/init.d/xtreemfs-osd #{service_file}"

    not_if { File.exists?(service_file) }
  end

  ruby_block "edit #{service_file}" do
    block do
      rc = Chef::Util::FileEdit.new(service_file)
      rc.search_file_replace("CONFIG=/etc/xos/xtreemfs/osdconfig.properties", "CONFIG=/etc/xos/xtreemfs/osdconfig.#{osd_number}.properties")
      rc.search_file_replace("PID=/var/run/xtreemfs_osd.pid", "PID=/var/run/xtreemfs_osd.#{osd_number}.pid")
      rc.search_file_replace("LOG=/var/log/xtreemfs/osd.log", "LOG=/var/log/xtreemfs/osd.#{osd_number}.log")
      rc.write_file
    end
  end

  service "xtreemfs-osd.#{osd_number}" do
    action [ :enable, :start ]
  end
end
