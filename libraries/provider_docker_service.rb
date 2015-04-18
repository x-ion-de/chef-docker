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

      def docker_daemon_cmd
        cmd = "#{docker_bin} -d"
        cmd << " --api-cors-header=#{new_resource.api_cors_header}" if new_resource.api_cors_header
        cmd << " --bridge=#{new_resource.bridge}" if new_resource.bridge
        cmd << " --bip=#{new_resource.bip}" if new_resource.bip
        cmd << ' --debug' if new_resource.debug
        cmd << ' --daemon=true' if new_resource.daemon
        cmd << " --default-ulimit=#{new_resource.default_ulimit}" if new_resource.default_ulimit
        cmd << " --dns=#{new_resource.dns}" if new_resource.dns
        cmd << " --dns-search=#{new_resource.dns_search}" if new_resource.dns_search
        cmd << " --exec-driver=#{new_resource.exec_driver}" if new_resource.exec_driver
        cmd << " --fixed-cidr=#{new_resource.fixed_cidr}" if new_resource.fixed_cidr
        cmd << " --fixed-cidr-v6=#{new_resource.fixed_cidr_v6}" if new_resource.fixed_cidr_v6
        cmd << " --group=#{new_resource.group}" if new_resource.group
        cmd << " --graph=#{new_resource.graph}" if new_resource.graph
        cmd << " --host=#{new_resource.host}" if new_resource.host
        cmd << ' --icc=true' if new_resource.icc
        cmd << " --insecure-registry=#{new_resource.insecure_registry}" if new_resource.insecure_registry
        cmd << " --ip=#{new_resource.ip}" if new_resource.ip
        cmd << ' --ip-forward=true' if new_resource.ip_forward
        cmd << ' --ip-masq=true' if new_resource.ip_masq
        cmd << ' --iptables=true' if new_resource.iptables
        cmd << ' --ipv6=true' if new_resource.ipv6
        cmd << " --log-level=#{new_resource.log_level}" if new_resource.log_level
        cmd << " --label=#{new_resource.label}" if new_resource.label
        cmd << " --log-driver=#{new_resource.log_driver}" if new_resource.log_driver
        cmd << " --mtu=#{new_resource.mtu}" if new_resource.mtu
        cmd << " --pidfile=#{new_resource.pidfile}" if new_resource.pidfile
        cmd << " --registry-mirror=#{new_resource.registry_mirror}" if new_resource.registry_mirror
        cmd << " --storage_driver=#{new_resource.storage_driver}" if new_resource.storage_driver
        cmd << ' --selinux-enabled=true' if new_resource.selinux_enabled
        cmd << " --storage-opt=#{new_resource.storage_opt}" if new_resource.storage_opt
        cmd << ' --tls=true' if new_resource.tls
        cmd << " --tlscacert=#{new_resource.tlscacert}" if new_resource.tlscacert
        cmd << " --tlscert=#{new_resource.tlscert}" if new_resource.tlscert
        cmd << " --tlskey=#{new_resource.tlskey}" if new_resource.tlskey
        cmd << ' --tlsverify=true' if new_resource.tlsverify
        cmd
      end

      # Start the service
      action :start do
        execute "docker-#{new_resource.name}" do
          command docker_daemon_cmd
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
