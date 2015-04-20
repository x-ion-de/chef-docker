class Chef
  class Provider
    class DockerService
      class Systemd < Chef::Provider::DockerService
        provides :docker_service, platform: 'fedora'

        action :start do
          # this is the main systemd unit file
          template "/usr/lib/systemd/system/#{docker_name}.service" do
            path "/usr/lib/systemd/system/#{docker_name}.service"
            source 'systemd/docker.service.erb'
            owner 'root'
            group 'root'
            mode '0644'
            variables(
              config: new_resource,
              docker_daemon_cmd: docker_daemon_cmd
              )
            cookbook 'docker'
            notifies :run, "execute[systemctl daemon-reload]", :immediately
            action :create
          end

          # avoid 'Unit file changed on disk' warning
          execute "systemctl daemon-reload" do
            command '/usr/bin/systemctl daemon-reload'
            action :nothing
          end

          # tmpfiles.d config so the service survives reboot
          template "/usr/lib/tmpfiles.d/#{docker_name}.conf" do
            path "/usr/lib/tmpfiles.d/#{docker_name}.conf"
            source 'systemd/tmpfiles.d.conf.erb'
            owner 'root'
            group 'root'
            mode '0644'
            variables(config: new_resource)
            cookbook 'docker'
            action :create
          end

          # service management resource
          service "#{docker_name}" do
            service_name docker_name
            provider Chef::Provider::Service::Systemd
            supports restart: true, status: true
            action [:enable, :start]
          end
        end

        action :stop do
          # service management resource
          service "#{docker_name}" do
            service_name docker_name
            provider Chef::Provider::Service::Systemd
            supports status: true
            action [:disable, :stop]
            only_if { ::File.exist?("/usr/lib/systemd/system/#{docker_name}.service") }
          end
        end

        action :restart do
          # service management resource
          service "#{docker_name}" do
            service_name docker_name
            provider Chef::Provider::Service::Systemd
            action :reload
          end
        end
      end
    end
  end
end
