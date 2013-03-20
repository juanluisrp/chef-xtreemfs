require 'spec_helper'

describe 'xtreemfs::client' do
  context 'on ubuntu' do
    let(:runner) do
      ChefSpec::ChefRunner.new(platform:'ubuntu').converge('xtreemfs::client')
    end

    it 'should install the correct packages' do
      runner.should install_package 'xtreemfs-client'
    end
  end
end
