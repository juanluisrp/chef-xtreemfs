require 'spec_helper'

describe 'xtreemfs::dir' do
  context 'on ubuntu' do
    let(:runner) do
      ChefSpec::ChefRunner.new(platform:'ubuntu').converge('xtreemfs::dir')
    end

    it 'should install the correct packages' do
      runner.should install_package 'xtreemfs-server'
    end

    it 'should enable directory service' do
      runner.should enable_service 'xtreemfs-dir'
    end

    it 'should start directory service' do
      runner.should start_service 'xtreemfs-dir'
    end
  end
end
