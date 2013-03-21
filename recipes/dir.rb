package "xtreemfs-server"

service "xtreemfs-dir" do
  action [ :enable, :start ]
end

node.set[:xtreemfs][:dir][:service] = true
