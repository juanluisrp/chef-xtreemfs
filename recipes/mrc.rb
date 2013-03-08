package "xtreemfs-server"

node[:xtreemfs][:mrc][:uuid] ||= `uuidgen -r`

# TODO: Support multiple dir_services
dir_service_host = search(:node, 'role:xtreemfs*').map {|n| n['ipaddress']}.first

template "/etc/xos/xtreemfs/mrcconfig.properties" do
  source "mrcconfig.properties.erb"
  mode 0440
  owner node[:xtreemfs][:user]
  group node[:xtreemfs][:group]
  variables({
     :dir_service_host => dir_service_host,
     :uuid => node[:xtreemfs][:mrc][:uuid]
  })
end

service "xtreemfs-mrc" do
  action [ :enable, :start ]
end
