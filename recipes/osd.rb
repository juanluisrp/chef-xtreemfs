package "xtreemfs-server"

dir_service_host = search(:node, 'role:xtreemfs*').map {|n| n['ipaddress']}.first

0.upto(node[:xtreemfs][:osd][:count]) do |osd_number|
template "/etc/xos/xtreemfs/osdconfig.#{osd_number}.properties" do
  osd_id = "osd#{osd_number}_uuid"
  node[:xtreemfs][:osd][osd_id.to_sym] ||= `uuidgen -r`
  source "osdconfig.properties.erb"
  mode 0440
  owner node[:xtreemfs][:user]
  group node[:xtreemfs][:group]
  variables({
     :dir_service_host => dir_service_host,
     :object_directory => File.join(node[:xtreemfs][:osd][:object_base_directory], osd_number.to_s),
     :listen_port => (node[:xtreemfs][:osd][:first_listen_port] + osd_number),
     :http_port => (node[:xtreemfs][:osd][:first_http_port] + osd_number),
     :uuid => node[:xtreemfs][:osd][osd_id.to_sym],
     :listen_address => node[:xtreemfs][:osd][:ip]
  })
end

## Copy start script and replace properties
# execute "create service for OSD #{osd_number}" do
#   service_file = "/etc/init.d/xtreemfs-osd.#{osd_number}"
#   command "cp /etc/init.d/xtreemfs-osd #{service_file} && sed -i s/osdconfig\.properties/osdconfig\.#{osd_number}\.properties/ #{service_file} && sed -i s/xtreemfs_osd\.pid/xtreemfs_osd\.#{osd_number}.pid/ #{service_file}  && sed -i s/osd\.log/osd\.#{osd_number}.log/ #{service_file} "
#   not_if { File.exists?(service_file) } 
# end

service_file = "/etc/init.d/xtreemfs-osd.#{osd_number}"
  
script "create service for OSD #{osd_number}" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
cp /etc/init.d/xtreemfs-osd #{service_file}
EOH
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

# file service_file do
#   
#   content File.read('/etc/init.d/xtreemfs-osd').gsub("osdconfig.properties", "osdconfig.#{osd_number}.properties").
#                                   gsub("xtreemfs_osd.pid", "xtreemfs_osd.#{osd_number}.pid").
#                                   gsub("osd.log", "osd.#{osd_number}.log")
# end

service "xtreemfs-osd.#{osd_number}" do
  action [ :enable, :start ]
end

end
 