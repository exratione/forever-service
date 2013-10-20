#
# Install a service definition to /etc/init.
#
# Upstart services don't need enabling in the same way as init.d service
# definitions.
#

execute 'start-upstart-service' do
  command "start #{node['forever-service']['identifier']}"
  action :nothing
end

template "/etc/init/#{node['forever-service']['identifier']}.conf" do
  source 'upstart.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  notifies :run, resources(:execute => 'start-upstart-service')
end
