#
# Install a service definition to /etc/init.d.
#

# Enable the service.
service node['forever-service']['identifier'] do
  supports [:restart, :status]
  action :nothing
end

template "/etc/init.d/#{node['forever-service']['identifier']}" do
  source 'initd.erb'
  owner 'root'
  group 'root'
  mode 00755
  notifies :enable, resources(:service => node['forever-service']['identifier'])
  notifies :start, resources(:service => node['forever-service']['identifier'])
end
