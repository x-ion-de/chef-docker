require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class DockerContainerService < Chef::Provider::LWRPBase
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        create_service
      end

      action :remove do
        remove_service
      end

      action :start do
        start_service
      end

      action :stop do
        stop_service
      end

      action :restart do
        restart_service
      end

      action :enable do
        enable_service
      end

      action :disable do
        disable_service
      end


      def create_service
        # Throw error, they must define this
      end

      def remove_service
        service new_resource.service_name do
          action [:stop, :disable]
        end
      end

      def start_service
        service new_resource.service_name do
          action :start
        end
      end

      def stop_service
        service new_resource.service_name do
          action :stop
        end
      end

      def restart_service
        service new_resource.service_name do
          action :restart
        end
      end

      def enable_service
        service new_resource.service_name do
          action :enable
        end
      end

      def disable_service
        service new_resource.service_name do
          action :disable
        end
      end
    end
  end
end
