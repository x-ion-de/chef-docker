require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class DockerContainer < Chef::Resource::LWRPBase

      self.resource_name = :docker_container
      actions :commit, :cp, :export, :kill, :redeploy, :remove, :remove_link,
        :remove_volume, :restart, :run, :start, :stop, :wait
      default_action :run

      attr_accessor :id, :running, :exists, :created

      attribute :attach, :kind_of => [TrueClass, FalseClass]
      attribute :author, :kind_of => [String]
      attribute :cidfile, :kind_of => [String]
      attribute :cmd_timeout, :kind_of => [Integer], :default => node['docker']['container_cmd_timeout']
      attribute :command, :kind_of => [String]
      attribute :container_name, :name_attribute => true, :kind_of => [String]
      attribute :cpu_shares, :kind_of => [Fixnum]
      attribute :destination, :kind_of => [String]
      attribute :detach, :kind_of => [TrueClass, FalseClass]
      attribute :dns, :kind_of => [String, Array]
      attribute :dns_search, :kind_of => [String, Array]
      attribute :entrypoint, :kind_of => [String]
      attribute :env, :kind_of => [String, Array]
      attribute :env_file, :kind_of => [String]
      attribute :expose, :kind_of => [Fixnum, String, Array]
      attribute :force, :kind_of => [TrueClass, FalseClass]
      attribute :hostname, :kind_of => [String]
      attribute :init_type, :kind_of => [FalseClass, String], :default => node['docker']['container_init_type']
      attribute :interactive, :kind_of => [TrueClass, FalseClass], :default => false
      attribute :image, :kind_of => [String]
      attribute :link, :kind_of => [String, Array]
      attribute :label, :kind_of => [String]
      attribute :lxc_conf, :kind_of => [String, Array]
      attribute :memory, :kind_of => [Fixnum]
      attribute :message, :kind_of => [String]
      attribute :net, :kind_of => [String], :regex => [
        /(host|bridge|none)/, /container:.*/
      ]
      attribute :opt, :kind_of => [String, Array]
      attribute :pause, :kind_of => [TrueClass, FalseClass], :default => true
      attribute :port, :kind_of => [String, Array]
      attribute :privileged, :kind_of => [TrueClass, FalseClass]
      attribute :publish_exposed_ports, :kind_of => [TrueClass, FalseClass]
      attribute :remove_automatically, :kind_of => [TrueClass, FalseClass]
      attribute :repository, :kind_of => [String]
      attribute :run, :kind_of => [String]
      attribute :signal, :kind_of => [String], :default => 'SIGKILL'
      attribute :socket_template, :kind_of => [String]
      attribute :source, :kind_of => [String]
      attribute :tag, :kind_of => [String]
      attribute :tty, :kind_of => [TrueClass, FalseClass]
      attribute :user, :kind_of => [String]
      attribute :volume, :kind_of => [String, Array]
      attribute :volumes_from, :kind_of => [String]
      attribute :working_directory, :kind_of => [String]
    end
  end
end
