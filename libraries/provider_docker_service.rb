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

      # actions :create, :delete, :start, :stop, :restart, :enable
      action :create do
      end

      action :delete do
      end

      action :start do
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
