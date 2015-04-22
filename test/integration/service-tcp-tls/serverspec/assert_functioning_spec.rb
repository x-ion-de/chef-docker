require 'serverspec'

set :backend, :exec
puts "os: #{os}"

ENV['DOCKER_CERT_PATH'] = '/tmp/kitchen/tls/'
ENV['DOCKER_HOST'] = 'tcp://127.0.0.1:2376'
ENV['DOCKER_TLS_VERIFY'] = '1'

describe process('docker') do
  it { should be_running }
end

describe command('docker ps') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/^CONTAINER/) }
end
