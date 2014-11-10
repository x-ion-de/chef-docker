require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class DockerContainerService < Chef::Resource::LWRPBase

      self.resource_name = :docker_container_service
      actions :create, :remove, :start, :stop, :enable, :disable
      default_action :create

      attribute :service_name, :name_attribute => true
      attribute :cmd_timeout, :default => node['docker']['container_cmd_timeout'], :kind_of => [Integer]
      attribute :port, :default => [], :kind_of => [String, Array]
    end
  end
end
