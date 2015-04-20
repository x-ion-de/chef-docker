class Chef
  class Provider
    class DockerService
      class Execute < Chef::Provider::DockerService
        # Start the service
        action :start do
          # Go doesn't support detaching processes natively, so we have
          # to manually fork it from the shell with &
          # https://github.com/docker/docker/issues/2758
          bash "docker-#{new_resource.name}" do
            code "#{docker_daemon_cmd} &>> #{docker_log} &"
            not_if "ps -ef | awk '{ print $8 }' | grep ^#{docker_bin}$"
            action :run
          end
        end

        action :stop do
          execute "docker-#{new_resource.name}" do
            command 'kill `pidof docker`'
            only_if "ps -ef | awk '{ print $8 }' | grep ^#{docker_bin}$"
          end
        end

        action :restart do
          action_stop
          action_start
        end

        action :enable do
          log 'action :enable not implemented on this provider'
        end
      end
    end
  end
end
