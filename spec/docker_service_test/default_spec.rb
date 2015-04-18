require 'spec_helper'

describe 'docker_service_test::default on centos-7.0' do
  cached(:default) do
    ChefSpec::SoloRunner.new(
      platform: 'centos',
      version: '7.0',
    # step_into: 'docker_service'
    ) do |node|
      node.set['docker']['version'] = nil
    end.converge('docker_service_test::default')
  end

  # Resource in docker_service_test::default
  context 'compiling the test recipe' do
    it 'creates docker_service[default]' do
      expect(default).to create_docker_service('default')
    end
  end
end
