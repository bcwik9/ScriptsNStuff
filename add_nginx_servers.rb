def get_nginx_server_def opt={}
  project_location = opt[:project_location]
  listen_port = opt[:listen] || 80
  forward_port = opt[:forward]
  passenger_app_env = opt[:passenger_app_env] || 'development'
  server_name = opt[:server_name] || 'localhost'  

  raise 'Must specify project location or port to forward to' if project_location.nil? and forward_port.nil?
  
  # every server in nginx config tends to have these values
  server = [ 
            "server {",
            "listen #{listen_port};",
            "server_name #{server_name};"
           ]
  
  # by default, use passenger
  # otherwise, just forward traffic
  if project_location
    server += [
               "passenger_enabled on;",
               "passenger_app_env #{passenger_app_env};",
               "root #{project_location};",
              ]
  else
    server += [
               "location / {",
               "proxy_pass http://#{server_name}:#{forward_port};",
               "}"
              ]
  end
  
  # close server section
  server.push '}'

  # return a single string with newlines
  return server.join "\n"
end



# *** MAIN ***
USAGE = 'Specify servers in the form of <listenPort|subdomain>:<forwardPort|projectRoot>'

# figure out what nginx config file we're editing
nginx_conf = ENV['NGINX_CONF_LOCATION'] || '/opt/nginx/conf/nginx.conf'
raise "Warning: #{nginx_conf} doesn't exist!" unless File.exists? nginx_conf

# iterate through nginx config file and keep all the lines
# until we reach the server definition section
temp_nginx_conf_file = []
File.open(nginx_conf).readlines.each do |line|
  break if line =~ /server\s*{/
  temp_nginx_conf_file.push line
end

# figure out if we're adding servers from ARGV or ENV var
servers = ARGV
if servers.empty? and ENV['NGINX_SERVER_LIST']
  servers = ENV['NGINX_SERVER_LIST'].split ','
end
raise "No servers to add. #{USAGE}" if servers.nil? or servers.empty?

# add servers
servers.each do |v|
  server_spec = v.split ':'
  raise "Invalid server specification. #{USAGE}" if server_spec.size != 2
  
  # determine if we're listening to a specific port or
  # looking out for a subdomain on (default) port 80
  opt = {}
  if server_spec.first =~ /\d+/
    opt[:listen] = server_spec.first
  else
    opt[:server_name] = server_spec.first
  end

  # determine where the traffic is routed to
  if server_spec.last =~ /\d+/
    opt[:forward] = server_spec.last
  else
    opt[:project_location] = server_spec.last
  end

  # generate nginx server spec and add it to our temp config file
  temp_nginx_conf_file.push get_nginx_server_def(opt)
end

# close http section
temp_nginx_conf_file.push '}'

# create new nginx config file
File.open nginx_conf, 'w' do |f| f.puts temp_nginx_conf_file end
