require 'spec_helper'

describe 'xtreemfs::osd' do
  context 'on ubuntu' do
    let(:runner) do
      ChefSpec::ChefRunner.new(platform:'ubuntu').converge('xtreemfs::osd')
    end

    it 'should install the correct packages' do
      runner.should install_package 'xtreemfs-server'
    end

    [0, 1].each do |num|
      it "should enable osd service ##{num}" do
        runner.should enable_service "xtreemfs-osd.#{num}"
      end

      it 'should start mrc service' do
        runner.should start_service "xtreemfs-osd.#{num}"
      end
    
      it "should set UUID" do
        runner.node[:xtreemfs][:osd][:"osd#{num}_uuid"].should_not be_nil
      end
      
      describe "script create service for OSD #{num}" do
        it "should execute as root" do
          runner.should execute_bash_script("create service for OSD #{num}").with(:user => 'root')
        end
        
        it "should copy service" do
          runner.should execute_bash_script("create service for OSD #{num}").with(:code => /cp(.*?)xtreemfs-osd(.*?)xtreemfs-osd\.#{num}/)
        end
      end
      
      it "should run ruby block" do
        runner.should execute_ruby_block("edit /etc/init.d/xtreemfs-osd.#{num}")
      end
    
      describe "/etc/xos/xtreemfs/osdconfig.#{num}.properties" do
        before do
          @file = runner.template "/etc/xos/xtreemfs/osdconfig.#{num}.properties"
        end
        
        it "should be owned by xtreemfs" do
          @file.should be_owned_by "xtreemfs", "xtreemfs"
        end
        
        it "should list on node's IP" do
          runner.should create_file_with_content "/etc/xos/xtreemfs/osdconfig.#{num}.properties", "listen.address = #{runner.node.to_hash.ipaddress}"
        end
        
        it "should have node's IP as service host" do
          runner.should create_file_with_content "/etc/xos/xtreemfs/osdconfig.#{num}.properties", "dir_service.host = #{runner.node.to_hash.ipaddress}"
        end
        
        it "should contain the node's UUID" do
          runner.should create_file_with_content "/etc/xos/xtreemfs/osdconfig.#{num}.properties", runner.node.to_hash.xtreemfs.osd["osd#{num}_uuid"]
        end
      end
    end
  end
end
