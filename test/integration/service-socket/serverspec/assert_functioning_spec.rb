require 'serverspec'

set :backend, :exec
puts "os: #{os}"

ENV['DOCKER_HOST'] = 'unix:///var/run/docker.sock'

describe process('docker') do
  it { should be_running }
end

describe command('docker ps') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^CONTAINER/) }
end
