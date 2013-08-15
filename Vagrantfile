require 'vagrant-berkshelf'
require 'vagrant-omnibus'

Vagrant.configure("2") do |config|
  config.omnibus.chef_version = :latest

  config.vm.box = "precise64"

  config.ssh.max_tries = 40
  config.ssh.timeout   = 120

  run_lists = {
    "x1" => [
              "recipe[xtreemfs::dir]",
              "recipe[xtreemfs::mrc]",
              "recipe[xtreemfs::osd]",
              "recipe[autoetchosts]"
            ],
    "x2" => [
              "recipe[xtreemfs::mrc]",
              "recipe[xtreemfs::dir]",
              "recipe[xtreemfs::osd]",
              "recipe[autoetchosts]"

            ],
    "x3" => [
              "recipe[xtreemfs::dir]",
              "recipe[xtreemfs::mrc]",
              "recipe[xtreemfs::client]",
              "recipe[xtreemfs::osd]",
              "recipe[autoetchosts]"

            ]
  }

  (1..3).each do |i|
    config.vm.define "x#{i}".to_s do |v|
      v.vm.hostname = "x#{i}"
      v.vm.network :private_network, ip: "33.33.33.#{10+i}"
      v.vm.provision :chef_solo do |chef|
          chef.data_bags_path = "data_bags"
          chef.json = {
            :xtreemfs => {
              :standalone => false,
              :osd => {
                :bind_ip => "33.33.33.#{10+i}"
              },
              :mrc => {
                :replication => true,
                :bind_ip => "33.33.33.#{10+i}"
              },
              :dir => {
                :replication => true,
                :bind_ip => "33.33.33.#{10+i}"
              }
            }
          }
          chef.run_list = run_lists["x#{i}"]
      end
    end
  end

end
