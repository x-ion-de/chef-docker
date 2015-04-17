class Chef
  class Resource
    class DockerService < Chef::Resource::LWRPBase
      # Manually set the resource name because we're creating the classes
      # manually instead of letting the resource/ and providers/
      # directories auto-name things.
      self.resource_name = :docker_service

      # resource actions
      actions :create, :delete, :start, :stop, :restart, :enable
      default_action :create

      # register with the resource resolution system
      provides :docker_service
    end
  end
end
