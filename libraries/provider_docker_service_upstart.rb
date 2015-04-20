class Chef
  class Provider
    class DockerService
      class Upstart < Chef::Provider::DockerService
        provides :docker_service, platform_family: 'ubuntu'

        action :start do
          template '/etc/init/docker.conf' do
            path '/etc/init/docker.conf'
            source 'upstart/docker.conf.erb'
            owner 'root'
            group 'root'
            mode '0644'
            variables(
              config: new_resource,
              docker_daemon_cmd: docker_name
            )
            cookbook 'docker'
            action :create
          end

          service 'docker' do
            provider Chef::Provider::Service::Upstart
            supports status: true
            action [:start]
          end
        end

        action :stop do
          service 'docker' do
            provider Chef::Provider::Service::Upstart
            supports restart: true, status: true
            action [:stop]
          end
        end

        action :restart do
          service 'docker' do
            provider Chef::Provider::Service::Upstart
            action :stop
          end

          service 'docker' do
            provider Chef::Provider::Service::Upstart
            action :start
          end
        end
      end
    end
  end
end
