#
# Cookbook Name:: xtreemfs
# Recipe:: client
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
  
package "xtreemfs-client"

dir_service_host = search(:node, node[:xtreemfs][:dir][:query]).map {|n| n[:xtreemfs][:dir][:bind_ip]}.first
mrc_service_host = search(:node, node[:xtreemfs][:mrc][:query]).map {|n| n[:xtreemfs][:mrc][:bind_ip]}.first

# create all volumes explicitly defined or used in mounts
node[:xtreemfs][:client][:mounts].map {|m| m[:volume] }.concat(node[:xtreemfs][:client][:volumes]).uniq.each do |volume|
  Chef::Log.debug("Ensuring existence of volume #{volume} on MRC #{mrc_service_host}")
  execute "mkfs.xtreemfs #{mrc_service_host}/#{volume}" do
    not_if "lsfs.xtreemfs #{mrc_service_host} | sed -e 's/\\t\\(.*\\)\\t->.*$/\\1/' -e 'tx' -e 'd' -e ':x' | grep #{volume}"
  end
end

node[:xtreemfs][:client][:mounts].each do |mount|

  Chef::Log.debug("mount #{mrc_service_host}/#{mount[:volume]} on #{mount[:mnt]}")

  directory mount[:mnt]

  # NB monkeypatch in library/mount.rb
  mount mount[:mnt] do
    device "#{dir_service_host}/#{mount[:volume]}"
    options "rw,nosuid,nodev,noatime,allow_other,default_permissions"
    fstype 'xtreemfs'
    action [:enable, :mount]
  end

end
