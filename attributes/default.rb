default[:xtreemfs][:standalone] = Chef::Config[:solo]
default[:xtreemfs][:user] = "xtreemfs"
default[:xtreemfs][:group] = "xtreemfs"
default[:xtreemfs][:use_hostnames] = true

default[:xtreemfs][:repo] = {
  :uri => "http://download.opensuse.org/repositories/home:/xtreemfs/xUbuntu_#{node['lsb']['release']}",
  :key => "http://download.opensuse.org/repositories/home:/xtreemfs/xUbuntu_#{node['lsb']['release']}/Release.key",
  :distribution => './'
}
# MRC defaults

default[:xtreemfs][:mrc][:dir_service_host] = "localhost"

# OSD defaults

# Number of OSDs
default[:xtreemfs][:osd][:count] = 1
default[:xtreemfs][:osd][:first_listen_port] = 32640
default[:xtreemfs][:osd][:first_http_port] = 30640
default[:xtreemfs][:osd][:bind_ip] = node[:ipaddress]

# MRC defaults
default[:xtreemfs][:mrc][:replication] = false
default[:xtreemfs][:mrc][:bind_ip] = node[:ipaddress]
default[:xtreemfs][:mrc][:listen_port] = 32636
default[:xtreemfs][:mrc][:http_port] = 30636
default[:xtreemfs][:mrc][:repl_port] = 35676

# DIR defaults
default[:xtreemfs][:dir][:replication] = false
default[:xtreemfs][:dir][:bind_ip] = node[:ipaddress]
default[:xtreemfs][:dir][:listen_port] = 32638
default[:xtreemfs][:dir][:http_port] = 30638
default[:xtreemfs][:dir][:snmp_port] = 34638
default[:xtreemfs][:dir][:repl_port] = 35678

# We don't want to get to fancy with configuration so we use the following convention:
# "object_base_directory" is configured here and the OSD dirs will be based on the OSD number
#
# /var/lib/xtreemfs/objs/0
# /var/lib/xtreemfs/objs/1
# /var/lib/xtreemfs/objs/2
# /var/lib/xtreemfs/objs/3
#
# etc.
# 
# So just mount your disks to these directories and xtreemfs will handle each disk(set)
# mounted in these directories with one OSD
default[:xtreemfs][:osd][:object_base_directory] = "/var/lib/xtreemfs/objs/"
