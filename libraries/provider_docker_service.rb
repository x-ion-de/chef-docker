class Chef
  class Provider
    class DockerService < Chef::Provider::LWRPBase
      # Create a run_context for provider instances.
      # Each provider action becomes an isolated recipe
      # with its own compile/converger cycle.
      use_inline_resources

      # Because we're using convergent Chef resources to manage
      # machine state, we can say why_run is supported for the
      # composite.
      def whyrun_supported?
        true
      end

      # Mix in helpers from libraries/helpers.rb
      include DockerHelpers

      # Put the appropriate bits on disk.
      action :create do
        # Pull a precompiled binary off the network
        remote_file docker_bin do
          source parsed_source
          checksum parsed_checksum
          owner 'root'
          group 'root'
          mode '0755'
          action :create
        end
      end

      action :delete do
        file docker_bin do
          action :delete
        end
      end

      # Start the service
      action :start do
        # Go doesn't support detaching processes natively, so we have
        # to manually fork it from the shell with &
        # https://github.com/docker/docker/issues/2758
        execute "docker-#{new_resource.name}" do
          command "#{docker_daemon_cmd} &>> #{docker_log} &"
          not_if "ps -ef | awk '{ print $8 }' | grep ^#{docker_bin}$"
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
