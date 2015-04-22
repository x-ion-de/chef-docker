# comments!

docker_service 'machine_ipv4:2376' do
  host "tcp://#{node['ipaddress']}:2376"
  action [:create, :start]
end
