# Actions: :warn, :fatal
default['docker']['alert_on_error_action'] = :fatal

# DEPRECATED: Support for bind_socket/bind_uri
default['docker']['host'] =
  if node['docker']['bind_socket'] || node['docker']['bind_uri']
    Array(node['docker']['bind_socket']) + Array(node['docker']['bind_uri'])
  elsif node['docker']['init_type'] == 'systemd'
    'fd://'
  else
    'unix:///var/run/docker.sock'
  end

# LWRP attributes
default['docker']['docker_daemon_timeout'] = 10

## docker_container attributes
default['docker']['container_cmd_timeout'] = 60
default['docker']['container_init_type'] = node['docker']['init_type']

## docker_image attributes
default['docker']['image_cmd_timeout'] = 300

## docker_registry attributes
default['docker']['registry_cmd_timeout'] = 60
