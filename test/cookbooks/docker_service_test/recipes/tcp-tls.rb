# var
caroot = '/tmp/kitchen/tls'

# CA skeleton
directory "#{caroot}" do
  action :create
end

execute 'creating PKI index file' do
  command "/bin/touch #{caroot}/index.txt"
  not_if "/usr/bin/test -f #{caroot}/index.txt"
  action :run
end

execute 'starting PKI serial file' do
  command "/bin/echo '01' > #{caroot}/serial"
  not_if "/usr/bin/test -f #{caroot}/serial"
  action :run
end

execute 'starting crlnumber' do
  command "echo '01' > #{caroot}/ca.srl"
  not_if "/usr/bin/test -f #{caroot}/ca.srl"
  action :run
end

# extra stuff
file "#{caroot}/extfile.cnf" do
  content "subjectAltName = IP:#{node['ipaddress']},IP:127.0.0.1\n"
  action :create
end

# Self sicned CA
execute 'generating CA private key' do
  cmd = 'openssl req'
  cmd += ' -x509'
  cmd += ' -nodes'
  cmd += ' -days 3650'
  cmd += " -subj '/O=kitchen2docker/'"
  cmd += ' -newkey rsa:2048'
  cmd += " -keyout #{caroot}/cakey.pem"
  cmd += " -out #{caroot}/ca.pem"
  cmd += ' 2>&1>/dev/null'
  command cmd
  not_if "/usr/bin/test -f #{caroot}/cakey.pem"
  not_if "/usr/bin/test -f #{caroot}/ca.pem"
  action :run
end

# server certs
execute 'creating private key for docker server' do
  command "openssl genrsa -out #{caroot}/serverkey.pem 2048"
  not_if "/usr/bin/test -f #{caroot}/serverkey.pem"
  action :run
end

execute 'generating certificate request for server' do
  cmd = 'openssl req'
  cmd += ' -new'
  cmd += ' -nodes'
  cmd += " -subj '/O=kitchen2docker/'"
  cmd += " -key #{caroot}/serverkey.pem"
  cmd += " -out #{caroot}/server.csr"
  command cmd
  only_if "/usr/bin/test -f #{caroot}/serverkey.pem"
  not_if "/usr/bin/test -f #{caroot}/server.csr"
  action :run
end

execute 'signing request for server' do
  cmd = 'openssl x509'
  cmd += ' -req'
  cmd += " -CA #{caroot}/ca.pem"
  cmd += " -CAkey #{caroot}/cakey.pem"
  cmd += " -in #{caroot}/server.csr"
  cmd += " -out #{caroot}/server.pem"
  cmd += " -extfile #{caroot}/extfile.cnf"
  not_if "/usr/bin/test -f #{caroot}/server.pem"
  command cmd
  action :run
end

# client certs
execute 'creating private key for docker client' do
  command "openssl genrsa -out #{caroot}/key.pem 2048"
  not_if "/usr/bin/test -f #{caroot}/key.pem"
  action :run
end

execute 'generating certificate request for client' do
  cmd = 'openssl req'
  cmd += ' -new'
  cmd += ' -nodes'
  cmd += " -subj '/O=kitchen2docker/'"
  cmd += " -key #{caroot}/key.pem"
  cmd += " -out #{caroot}/cert.csr"
  command cmd
  only_if "/usr/bin/test -f #{caroot}/key.pem"
  not_if "/usr/bin/test -f #{caroot}/cert.csr"
  action :run
end

execute 'signing request for client' do
  cmd = 'openssl x509'
  cmd += ' -req'
  cmd += " -CA #{caroot}/ca.pem"
  cmd += " -CAkey #{caroot}/cakey.pem"
  cmd += " -in #{caroot}/cert.csr"
  cmd += " -out #{caroot}/cert.pem"
  command cmd
  not_if "/usr/bin/test -f #{caroot}/cert.pem"
  action :run
end

# start docker service listening on TCP port
docker_service 'tls_test:2376' do
  host 'tcp://127.0.0.1:2376'
  tlscacert "#{caroot}/ca.pem"
  tlscert "#{caroot}/server.pem"
  tlskey "#{caroot}/serverkey.pem"
  tlsverify true
  action [:create, :start]
end
