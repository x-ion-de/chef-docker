class Chef
  class Provider
    class DockerService
      class Sysvinit < Chef::Provider::DockerService
        provides :docker_service, platform: 'amazon'
        provides :docker_service, platform: 'centos'
        provides :docker_service, platform: 'redhat'
        provides :docker_service, platform: 'suse'

        # Start the service
        action :start do
          template "#{new_resource.instance} :start /etc/init.d/#{docker_name}" do
            path "/etc/init.d/#{docker_name}"
            source 'sysvinit/docker.erb'
            owner 'root'
            group 'root'
            mode '0755'
            cookbook 'docker'
            variables(config: new_resource,pidfile: parsed_pidfile)
            action :create
          end
        end

        action :stop do
        end

        action :restart do
          action_stop
          action_start
        end
      end
    end
  end
end
