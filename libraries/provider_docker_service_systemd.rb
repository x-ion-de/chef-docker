class Chef
  class Provider
    class DockerService
      class Systemd < Chef::Provider::DockerService
        provides :docker_service, platform: 'fedora'
        provides :docker_service, platform: %w(redhat centos scientific) do |node|
          node[:platform_version].to_f >= 7.0
        end

        action :start do
          # this is the main systemd unit file
          template '/usr/lib/systemd/system/docker.service' do
            path '/usr/lib/systemd/system/docker.service'
            source 'systemd/docker.service.erb'
            owner 'root'
            group 'root'
            mode '0644'
            variables(
              config: new_resource,
              docker_bin: docker_bin,
              docker_opts: docker_opts
            )
            cookbook 'docker'
            notifies :run, 'execute[systemctl daemon-reload]', :immediately
            action :create
          end

          # avoid 'Unit file changed on disk' warning
          execute 'systemctl daemon-reload' do
            command '/usr/bin/systemctl daemon-reload'
            action :nothing
          end

          # tmpfiles.d config so the service survives reboot
          template '/usr/lib/tmpfiles.d/docker.conf' do
            path '/usr/lib/tmpfiles.d/docker.conf'
            source 'systemd/tmpfiles.d.conf.erb'
            owner 'root'
            group 'root'
            mode '0644'
            variables(config: new_resource)
            cookbook 'docker'
            action :create
          end

          # service management resource
          service 'docker' do
            provider Chef::Provider::Service::Systemd
            supports restart: true, status: true
            action [:enable, :start]
          end
        end

        action :stop do
          # service management resource
          service 'docker' do
            provider Chef::Provider::Service::Systemd
            supports status: true
            action [:disable, :stop]
            only_if { ::File.exist?('/usr/lib/systemd/system/docker.service') }
          end
        end

        action :restart do
          action_stop
          action_start
        end
      end
    end
  end
end
