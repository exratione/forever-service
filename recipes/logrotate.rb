#
# Set up a default log rotation schedule.
#

begin
  include_recipe 'logrotate'
rescue
  Chef::Log.warn('The forever-service::logrotate recipe requires the logrotate cookbook.')
end

logrotate_app node['forever-service']['identifier'] do
  path File.dirname(node['forever-service']['log-file-path'])
  frequency 'weekly'
  rotate 52
  options ['missingok', 'compress', 'notifempty']
end
