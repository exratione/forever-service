#
# Install a service definition to /etc/init.
#

template "/etc/init/#{node['forever-service']['identifier']}.conf" do
  source 'upstart.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
end
