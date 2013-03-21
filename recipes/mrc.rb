package "xtreemfs-server"

if node[:xtreemfs][:mrc][:uuid].nil?
  node.set[:xtreemfs][:mrc][:uuid] = `uuidgen`
end

# TODO: Support multiple dir_services
if Chef::Config[:solo]
  dir_service_host = node[:xtreemfs][:dir][:bind_ip]
else
  dir_service_host = search(:node, 'role:xtreemfs*').map {|n| n['ipaddress']}.first
end

template "/etc/xos/xtreemfs/mrcconfig.properties" do
  source "mrcconfig.properties.erb"
  mode 0440
  owner node[:xtreemfs][:user]
  group node[:xtreemfs][:group]
  variables({
     :dir_service_host => dir_service_host,
     :uuid => node[:xtreemfs][:mrc][:uuid],
     :ip_address => node[:xtreemfs][:mrc][:bind_ip]
  })
end

service "xtreemfs-mrc" do
  action [ :enable, :start ]
end

node.set[:xtreemfs][:mrc][:service] = true
