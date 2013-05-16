default[:xtreemfs][:user] = "xtreemfs"
default[:xtreemfs][:group] = "xtreemfs"

# DIR defaults

default[:xtreemfs][:dir][:bind_ip] = node[:ipaddress]
default[:xtreemfs][:dir][:query] = 'xtreemfs_dir_service:true'

# MRC defaults

default[:xtreemfs][:mrc][:dir_service_host] = "localhost"
default[:xtreemfs][:mrc][:query] = 'xtreemfs_mrc_service:true'
default[:xtreemfs][:mrc][:bind_ip] = node[:ipaddress]

# OSD defaults

# Number of OSDs
default[:xtreemfs][:osd][:count] = 1
default[:xtreemfs][:osd][:first_listen_port] = 32640
default[:xtreemfs][:osd][:first_http_port] = 30640
default[:xtreemfs][:osd][:bind_ip] = node[:ipaddress]

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

