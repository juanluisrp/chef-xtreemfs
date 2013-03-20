#
# Cookbook Name:: xtreemfs
# Recipe:: default
#
# Copyright (C) 2013 Cloudbau GmbH
# 
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"

key_id = "2FA7E736"

bash "install xtreemfs key" do
  code "wget -q http://download.opensuse.org/repositories/home:/xtreemfs/xUbuntu_#{node['lsb']['release']}/Release.key -O - | sudo apt-key add -"
  not_if "apt-key list | grep #{key_id}"
end

apt_repository "xtreemfs" do
  uri "http://download.opensuse.org/repositories/home:/xtreemfs/xUbuntu_#{node['lsb']['release']}"
  distribution "./"
end

bash "forced apt-get update" do
  code "apt-get update"
end

