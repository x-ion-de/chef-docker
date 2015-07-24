# Note(JR): Unmask docker.(service|socket) for Ubuntu Vivid
# Need to check where this comes from initially.
%w(service socket).each do |type|
  file "/etc/systemd/system/docker.#{type}" do
    action :delete
    force_unlink true
    notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  end
end

execute 'systemctl-daemon-reload' do
  command '/bin/systemctl --system daemon-reload'
  action :nothing
end

template ::File.join(node['docker']['systemd_system_dir'], 'docker.socket') do
  source 'docker.socket.erb'
  mode '0644'
  owner 'root'
  group 'root'
end

template ::File.join(node['docker']['systemd_system_dir'], 'docker.service') do
  source 'docker.service.erb'
  mode '0644'
  owner 'root'
  group 'root'
  variables(
    'daemon_options' => Docker::Helpers.daemon_cli_args(node)
  )
  notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  notifies :restart, 'service[docker]', :immediately
end

service 'docker' do
  provider Chef::Provider::Service::Systemd
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end
