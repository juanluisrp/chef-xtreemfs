require 'spec_helper'

describe 'xtreemfs::default' do
  context 'on ubuntu' do
    let(:runner) do
      ChefSpec::ChefRunner.new(platform:'ubuntu', cookbook_path:'cookbooks') do |node|
        node.set['lsb']['release'] = "foobar"
      end.converge('xtreemfs::default')
    end

    it 'should define apt repository' do
      runner.should add_apt_repository 'xtreemfs'
    end
  end
end
