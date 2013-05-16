#
# Cookbook Name:: xtreemfs
# Recipe:: default
#
# Copyright (C) 2013 Cloudbau GmbH
# 
# All rights reserved - Do Not Redistribute
#

if node.platform?("ubuntu")

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

elsif node.platform?("centos")

  include_recipe "yum"

  major_version = node.platform_version.split(".").first

  yum_key "RPM-GPG-KEY-xtreemfs" do
    url "http://download.opensuse.org/repositories/home:/xtreemfs/CentOS_#{major_version}/repodata/repomd.xml.key"
    action :add
  end

  yum_repository "xtreemfs" do
    description "XtreemFS (CentOS_#{major_version})"
    url "http://download.opensuse.org/repositories/home:/xtreemfs/CentOS_#{major_version}/"
    key "RPM-GPG-KEY-xtreemfs"
    action :add
  end

end
