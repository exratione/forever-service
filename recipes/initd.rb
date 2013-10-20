#
# Install a service definition to /etc/init.d.
#

template "/etc/init.d/#{node['forever-service']['identifier']}" do
  source 'initd.erb'
  owner 'root'
  group 'root'
  mode 00755
end
