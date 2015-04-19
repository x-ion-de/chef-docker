module DockerHelpers
  # Path to docker executable
  def docker_arch
    node['kernel']['machine']
  end

  def docker_bin
    '/usr/bin/docker'
  end

  def docker_kernel
    node['kernel']['name']
  end

  def parsed_checksum
    case docker_arch
    when 'Darwin'
      case parsed_version
      when '0.10.0' then '416835b2e83e520c3c413b4b4e4ae34bca20704f085b435f4c200010dd1ac3b7'
      when '0.11.0' then '9db839b56a8656cfcef1f6543e9f75b01a774fdd6a50457da20d8183d6b415fa'
      when '0.11.1' then '386ffa26e52856107efb0b3075625d5b2331fa5acc8965fef87c1ab7d900c4e9'
      when '0.12.0' then 'a38dccb7f544fad4ef2f95243bef7e2c9afbd76de0e4547b61b27698bf9065f3'
      when '1.0.0' then '67c3c9f285584533ac365a56515f606fc91d4dcd0bfa69c2f159eeb5e37ea3b8'
      when '1.0.1' then 'b662e7718f0a8e23d2e819470a368f257e2bc46f76417712360de7def775e9d4'
      end
    when 'Linux'
      case parsed_version
      when '0.10.0' then 'ce1f5bc88a99f8b2331614ede7199f872bd20e4ac1806de7332cbac8e441d1a0'
      when '0.11.0' then 'f80ba82acc0a6255960d3ff6fe145a8fdd0c07f136543fcd4676bb304daaf598'
      when '0.11.1' then 'ed2f2437fd6b9af69484db152d65c0b025aa55aae6e0991de92d9efa2511a7a3'
      when '0.12.0' then '0f611f7031642a60716e132a6c39ec52479e927dfbda550973e1574640135313'
      when '1.0.0' then '55cf74ea4c65fe36e9b47ca112218459cc905ede687ebfde21b2ba91c707db94'
      when '1.0.1' then '1d9aea20ec8e640ec9feb6757819ce01ca4d007f208979e3156ed687b809a75b'
      when '1.6.0' then '526fbd15dc6bcf2f24f99959d998d080136e290bbb017624a5a3821b63916ae8'
      end
    end
  end

  def parsed_version
    return new_resource.version if new_resource.version
    '1.6.0'
  end

  def parsed_source
    return new_resource.source if new_resource.source
    "http://get.docker.io/builds/#{docker_kernel}/#{docker_arch}/docker-#{parsed_version}"
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
end
