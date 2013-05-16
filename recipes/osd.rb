package "xtreemfs-server"

# TODO: Support multiple dir_services
if Chef::Config[:solo]
  dir_service_host = node[:xtreemfs][:dir][:bind_ip]
else
  dir_service_host = search(:node, node[:xtreemfs][:dir][:query]).map {|n| n[:xtreemfs][:dir][:bind_ip]}.first
end

0.upto(node[:xtreemfs][:osd][:count]) do |osd_number|
  template "/etc/xos/xtreemfs/osdconfig.#{osd_number}.properties" do
    osd_id = :"osd#{osd_number}_uuid"
    if node[:xtreemfs][:osd][osd_id].nil?
      node.set[:xtreemfs][:osd][osd_id] = `uuidgen`
    end
    
    source "osdconfig.properties.erb"
    mode 0440
    owner node[:xtreemfs][:user]
    group node[:xtreemfs][:group]
    variables({
      :dir_service_host => dir_service_host,
      :object_directory => File.join(node[:xtreemfs][:osd][:object_base_directory], osd_number.to_s),
      :listen_port => (node[:xtreemfs][:osd][:first_listen_port] + osd_number),
      :http_port => (node[:xtreemfs][:osd][:first_http_port] + osd_number),
      :uuid => node[:xtreemfs][:osd][osd_id],
      :listen_address => node[:xtreemfs][:osd][:bind_ip]
    })
  end

  service_file = "/etc/init.d/xtreemfs-osd.#{osd_number}"
  
  script "create service for OSD #{osd_number}" do
    interpreter "bash"
    user "root"
    cwd "/tmp"
    code "cp /etc/init.d/xtreemfs-osd #{service_file}"

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

  service "xtreemfs-osd.#{osd_number}" do
    action [ :enable, :start ]
  end
end
