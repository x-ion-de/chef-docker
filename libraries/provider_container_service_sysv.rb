require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class DockerContainerService
      class Sysv < Chef::Provider::DockerContainerService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        def create_service
          template "/etc/init.d/#{new_resource.service_name}" do
            source 'docker-container.sysv.erb'
            mode '0755'
            owner 'root'
            group 'root'
            variables(
              :service_name => new_resource.service_name
            )
            action :create
          end

          service new_resource.service_name do
            action [:start, :enable]
          end
        end

        def remove_service
          super

          file "/etc/init.d/#{new_resource.service_name}" do
            action :delete
          end
        end
      end
    end
  end
end
