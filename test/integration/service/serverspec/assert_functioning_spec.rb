require 'serverspec'

set :backend, :exec

puts "os: #{os}"

describe process('docker') do
  it { should be_running }
end
