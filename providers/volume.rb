action :create do
  execute "create volume" do
    #not_if "mysql -e 'show databases;' | grep #{new_resource.name}"
    metadata_service = ""
    volume_name = ""
    command "mkfs.xtreemfs #{metadata_service}/#{volume_name}"
  end
end
 
action :destroy do
  execute "delete database" do
    only_if "mysql -e 'show databases;' | grep #{new_resource.name}"
    command "mysqladmin drop #{new_resource.name}"
  end
end