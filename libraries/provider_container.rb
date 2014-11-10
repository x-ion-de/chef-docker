require 'chef/provider/lwrp_base'
require_relative 'helpers_docker_container'

include DockerCookbook::Helpers::Container

class Chef
  class Provider
    class DockerContainer < Chef::Provider::LWRPBase
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      def load_current_resource
        wait_until_ready!
        @current_resource = Chef::Provider::DockerContainer.new(new_resource.name)

        info = shell_out("#{docker_bin} inspect #{new_resource.container_name}")

        @current_resource.created

        run_args = %w(
          cpu_shares
          cidfile
          dns
          dns_search
          env
          env_file
          entrypoint
          expose
          hostname
          interactice
          label
          link
          lxc_conf
          memory
          net
          networking
          opt
          port
          publish_exposed_ports
          privileged
          remove_automatically
          tty
          user
          volume
          volumes_from
          working_directory
        )

        @current_resource.image
        @current_resource.command

        @current_resource.exists
        @current_resource.running

        @current_resource
      end

      action :commit do
        commit_args = cli_args(
          'author' => new_resource.author,
          'message' => new_resource.message,
          'run' => new_resource.run,
          'pause' => new_resource.pause
        )

        commit_end_args = ''
        if new_resource.repository
          commit_end_args = new_resource.repository
          commit_end_args += ":#{new_resource.tag}" if new_resource.tag
        end

        execute "commit_#{new_resource.name}" do
          command "#{docker_bin} commit #{commit_args} #{@current_resource.id} #{commit_end_args}"
          only_if { @current_resource.exists }
        end
      end

      action :cp do
        check_for_required_attributes :source, :destination

        execute "cp_#{new_resource.name}" do
          command "#{docker_bin} cp #{@current_resource.id}:#{new_resource.source} #{new_resource.destination}"
          only_if { @current_resource.exists }
        end
      end

      action :export do
        check_for_required_attributes :destination

        execute "export_#{new_resource.name}" do
          command "#{docker_bin} export #{@current_resource.id} > #{new_resource.destination}"
          only_if { @current_resource.exists }
        end
      end

      action :kill do
        if @current_resource.service_exists?
          docker_container_service new_resource.container_name do
            only_if { @current_resource.exists }
          end
        end

        kill_args = cli_args(
          'signal' => new_resource.signal
        )
        execute "kill_#{new_resource.name}" do
          command "#{docker_bin} kill #{kill_args} #{@current_resource.id}"
          only_if { @current_resource.exists }
        end
      end

      action :redeploy do
        action_stop
        action_remove_container
        action_run
      end

      action :remove do
        action_stop

        if @current_resource.service_exists?
          docker_container_service new_resource.container_name do
            only_if { container_exists(@current_resource.id) }
            action :delete
          end
        end

        rm_args = cli_args(
          'force' => new_resource.force
        )
        execute "remove_container_#{new_resource.name}" do
          command "#{docker_bin} rm #{rm_args} #{@current_resource.id}"
          only_if { container_exists(@current_resource.id) }
        end

        if new_resource.cidefile
          file new_resource.cidfile do
            action :delete
          end
        end
      end

      action :remove_link do
        check_for_required_attributes :link

        rm_args = cli_args(
          'link' => true
        )

        link_args = Array(new_resource.link).map do |link|
          new_resource.container_name + '/' + link
        end

        execute "remove_link_#{new_resource.name}" do
          command "#{docker_bin} rm #{rm_args} #{link_args.join(' ')}"
          only_if { @current_resource.exists }
        end
      end

      action :remove_volume do
        check_for_required_attributes :volume

        rm_args = cli_args(
          'volume' => Array(new_resource.volume)
        )

        execute "remove_volume_#{new_resource.name}" do
          command "#{docker_bin} rm #{rm_args} #{@current_resource.id}"
          only_if { @current_resource.exists }
        end
      end

      action :restart do
        if @current_resource.service_exists?
          docker_container_service new_resource.container_name do
            action :restart
            only_if { @current_resource.exists }
          end
        else
          execute "restart_#{new_resource.name}" do
            command "#{docker_bin} restart #{@current_resource.id}"
            only_if { @current_resource.exists }
          end
        end
      end

      action :run do
        check_for_required_attributes :image, :command

        run_args = cli_args(
          'cpu-shares' => new_resource.cpu_shares,
          'cidfile' => new_resource.cidfile,
          'detach' => new_resource.detach,
          'dns' => Array(new_resource.dns),
          'dns-search' => Array(new_resource.dns_search),
          'env' => Array(new_resource.env),
          'env-file' => new_resource.env_file,
          'entrypoint' => new_resource.entrypoint,
          'expose' => Array(new_resource.expose),
          'hostname' => new_resource.hostname,
          'interactive' => new_resource.stdin,
          'label' => new_resource.label,
          'link' => Array(new_resource.link),
          'lxc-conf' => Array(new_resource.lxc_conf),
          'memory' => new_resource.memory,
          'net' => new_resource.net,
          'networking' => new_resource.networking,
          'name' => container_name,
          'opt' => Array(new_resource.opt),
          'publish' => Array(*new_resource.port),
          'publish-all' => new_resource.publish_exposed_ports,
          'privileged' => new_resource.privileged,
          'rm' => new_resource.remove_automatically,
          'tty' => new_resource.tty,
          'user' => new_resource.user,
          'volume' => Array(new_resource.volume),
          'volumes-from' => new_resource.volumes_from,
          'workdir' => new_resource.working_directory
        )

        execute "run_#{new_resource.name}" do
          command "#{docker_bin} #{run_args} #{new_resource.image} #{new_resource.command}"
        end

        docker_container_service new_resource.container_name do
          action :create
          only_if { new_resource.init_type }
        end
      end

      action :start do
        if new_resource.init_type
          docker_container_service new_resource.container_name do
            action [:start, :enable]
            not_if { @current_resource.running }
          end
        else
          start_args = cli_args(
            'attach' => new_resource.attach,
            'interactive' => new_resource.stdin
          )

          execute "start_#{new_resource.name}" do
            command "#{docker_bin} start #{start_args} #{@current_resource.id}"
            not_if { @current_resource.running }
          end
        end
      end

      action :stop do
        if @current_resource.service_exists?
          docker_container_service new_resource.container_name do
            only_if { @current_resource.running }
            action :stop
          end
        else
          stop_args = cli_args(
            'time' => new_resource.cmd_timeout
          )
          execute "stop_#{new_resource.name}" do
            command "#{docker_bin} stop #{stop_args} #{@current_resource.id}"
            only_if { @current_resource.running }
          end
        end
      end

      action :wait do
        execute "wait_#{new_resource.name}" do
          command "#{docker_bin} wait #{@current_resource.id}"
          only_if { @current_resource.running }
        end
      end
    end
  end
end
