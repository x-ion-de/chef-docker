require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class DockerContainerService
      class Runit < Chef::Provider::DockerContainerService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        def create_service
          include_recipe 'runit'

          runit_service new_resource.service_name do
            default_logger true
            options(
              'service_name' => new_resource.service_name
            )
            run_template_name 'docker-container'
            action :enable
          end
        end

        def remove_service
          runit_service new_resource.service_name do
            action :disable
          end
        end

        def start_service
          runit_service new_resource.service_name do
            action :start
          end
        end

        def stop_service
          runit_service new_resource.service_name do
            action :stop
          end
        end

        def restart_service
          runit_service new_resource.service_name do
            supports :restart => true
            action :restart
          end
        end

        def enable_service
          runit_service new_resource.service_name do
            action :enable
          end
        end

        def disable_service
          runit_service new_resource.service_name do
            action :disable
          end
        end

      end
    end
  end
end
