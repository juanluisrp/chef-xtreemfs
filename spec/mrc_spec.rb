require 'spec_helper'

describe 'xtreemfs::mrc' do
  context 'on ubuntu' do
    let(:runner) do
      ChefSpec::ChefRunner.new(platform:'ubuntu').converge('xtreemfs::mrc')
    end

    it 'should install the correct packages' do
      runner.should install_package 'xtreemfs-server'
    end

    it 'should enable mrc service' do
      runner.should enable_service 'xtreemfs-mrc'
    end

    it 'should start mrc service' do
      runner.should start_service 'xtreemfs-mrc'
    end
    
    it "should set UUID" do
      runner.node[:xtreemfs][:mrc][:uuid].should_not be_nil
    end
    
    describe "/etc/xos/xtreemfs/mrcconfig.properties" do
      before do
        @file = runner.template "/etc/xos/xtreemfs/mrcconfig.properties"
      end
      
      it "should be owned by xtreemfs" do
        @file.should be_owned_by "xtreemfs", "xtreemfs"
      end
      
      it "should contain node's IP as host name" do
        runner.should create_file_with_content "/etc/xos/xtreemfs/mrcconfig.properties", runner.node.to_hash.ipaddress
      end
      
      it "should contain the node's UUID" do
        runner.should create_file_with_content "/etc/xos/xtreemfs/mrcconfig.properties", runner.node.to_hash.xtreemfs.mrc.uuid
      end
    end
  end
end
