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
        execute "docker-#{new_resource.name}" do
          command "nohup #{docker_daemon_cmd} &"
          # not_if { docker_daemon_running? }
        end
      end

      action :stop do
      end

      action :restart do
      end

      action :enable do
      end
    end
  end
end
