#
# Install a service definition to /etc/init.d.
#

# Enable the service.
service 'forever-service' do
  service_name node['forever-service']['identifier']
  supports [:start, :stop, :restart, :status]
  action :nothing
end

template "/etc/init.d/#{node['forever-service']['identifier']}" do
  source 'initd.erb'
  owner 'root'
  group 'root'
  mode 00755
  notifies :enable, 'service[forever-service]'
  if node['forever-service']['start-service']
    notifies :start, 'service[forever-service]'
  end
end
