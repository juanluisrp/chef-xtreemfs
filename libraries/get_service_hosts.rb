def get_service_hosts(srv)
  if node[:xtreemfs][:standalone] or node[:xtreemfs][srv][:service]
    { node[:xtreemfs][srv][:bind_ip] => node[:xtreemfs][srv][:listen_port] }
  else
    Hash[search(:node, "xtreemfs_#{srv}_service:true").map {|n|  [ n[:xtreemfs][srv][:bind_ip], n[:xtreemfs][srv][:listen_port] ] } ]
  end
end
