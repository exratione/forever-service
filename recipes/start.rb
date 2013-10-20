#
# Start the service.
#

service node['forever-service']['identifier'] do
  action :start
end
