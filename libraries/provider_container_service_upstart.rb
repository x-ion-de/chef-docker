require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class DockerContainerService
      class Upstart < Chef::Provider::DockerContainerService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        def create_service
          # The upstart init script requires inotifywait, which is in inotify-tools
          package 'inotify-tools' do
            action :install
          end

          template "/etc/init/#{new_resource.service_name}.conf" do
            source 'docker-container.conf.erb'
            mode '0600'
            owner 'root'
            group 'root'
            variables(
              :cmd_timeout => new_resource.cmd_timeout,
              :service_name => new_resource.service_name
            )
            action :create
          end

          service new_resource.service_name do
            provider Chef::Provider::Service::Upstart
            action [:start, :enable]
          end
        end

        def remove_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Upstart
            action [:stop, :disable]
          end

          file "/etc/init/#{new_resource.service_name}.conf" do
            action :delete
          end
        end

        def start_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Upstart
            action :start
          end
        end

        def stop_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Upstart
            action :stop
          end
        end

        def restart_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Upstart
            supports :restart => true
            action :restart
          end
        end

        def enable_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Upstart
            action :enable
          end
        end

        def disable_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Upstart
            action :disable
          end
        end
      end
    end
  end
end
