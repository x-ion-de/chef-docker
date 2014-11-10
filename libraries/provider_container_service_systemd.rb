require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class DockerContainerService
      class Systemd < Chef::Provider::DockerContainerService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        def create_service
          template "/usr/lib/systemd/system/#{new_resource.service_name}.socket" do
            source 'docker-container.socket.erb'
            mode '0644'
            owner 'root'
            group 'root'
            variables(
              :service_name => new_resource.service_name,
              :sockets => [*new_resource.port].map { |p| p.gsub!(/.*:/, '') }
            )
            not_if port.empty?
            action :create
          end

          template "/usr/lib/systemd/system/#{new_resource.service_name}.service" do
            source 'docker-container.service.erb'
            mode '0644'
            owner 'root'
            group 'root'
            variables(
              :cmd_timeout => new_resource.cmd_timeout,
              :service_name => new_resource.service_name
            )
            action :create
          end

          service new_resource.service_name do
            provider Chef::Provider::Service::Systemd
            supports :restart => true, :reload => true, :status => true
            action [:start, :enable]
          end
        end

        def remove_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Systemd
            action [:stop, :disable]
          end

          %W(
            /usr/lib/systemd/system/#{new_resource.service_name}.socket
            /usr/lib/systemd/system/#{new_resource.service_name}.service
          ).each do |service_file|
            file service_file do
              action :delete
            end
          end
        end

        def start_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Systemd
            action :start
          end
        end

        def stop_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Systemd
            action :stop
          end
        end

        def restart_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Systemd
            supports :restart => true
            action :restart
          end
        end

        def enable_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Systemd
            action :enable
          end
        end

        def disable_service
          service new_resource.service_name do
            provider Chef::Provider::Service::Systemd
            action :disable
          end
        end
      end
    end
  end
end
