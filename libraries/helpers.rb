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
end
