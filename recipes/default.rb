#
# Install Node.js services running under Forever.
#

# Make sure that logrotate is available.
begin
  include_recipe 'logrotate'
rescue
  Chef::Log.error('The forever-service recipe requires the logrotate cookbook.')
end

# Install Forever globally.
execute "npm -g install forever@#{node['forever-service']['forever']['version']}"

# ----------------------------------------------------------------------------
# Loop through the service definitions.
# ----------------------------------------------------------------------------

node['forever-service']['services'].each do |identifier, definition|

  # --------------------------------------------------------------------------
  # Set some defaults.
  # --------------------------------------------------------------------------

  # Setting these defaults should help make errors a little more comprehensible.
  definition = {
    'description' => identifier,
    'display_name' => identifier,
    'enable' => false,
    'forever' => {
      'min_uptime' => 5000,
      'spin_sleep_time' => 2000
    },
    'log' => {
      'path' => false,
      'rotate' => {
        'frequency' => 'weekly',
        'rotate' => 52
      }
    },
    'pid_file_path' => '/var/run/#{identifier}.pid',
    'start_script' => '',
    'start_script_symlink' => false,
    'start' => true,
    'type' => 'initd',
    'user' => 'node'
  }.merge(definition)

  log "Examining service definition #{identifier}:"
  log definition

  # --------------------------------------------------------------------------
  # Skip this one if it is not set enabled.
  # --------------------------------------------------------------------------

  if !definition['enable']
    log "Service definition #{identifier} is not enabled. Skipping."
    next
  end

  # --------------------------------------------------------------------------
  # Make sure that the declared service user exists.
  # --------------------------------------------------------------------------

  # Note that the service launches as root: it is the responsibility of the
  # service to switch to using the declared user. We need to ensure that the
  # user exists so that we can correctly set up the log directory.
  user definition['user']

  # --------------------------------------------------------------------------
  # Set up the log directory.
  # --------------------------------------------------------------------------

  logdir = File.dirname(definition['log']['path'])
  directory logdir do
    action :create
    owner definition['user']
    group definition['user']
    mode 00775
    recursive true
    not_if { ::File.exists?(logdir) }
  end

  # --------------------------------------------------------------------------
  # Create a symlink to the start script.
  # --------------------------------------------------------------------------

  # By the way Forever works every service start script has to have a different
  # path in order to make things tractable in the service definitions.
  #
  # When running several identical processes from the same script it is thus
  # necessary to create symlinks to create different paths for Forever.
  if definition['start_script_symlink']
    link definition['start_script_symlink'] do
      to definition['start_script']
    end
  end

  # --------------------------------------------------------------------------
  # Install and start the service.
  # --------------------------------------------------------------------------

  # An init.d service.
  if definition['type'] == 'initd'
    service identifier do
      service_name identifier
      supports [:start, :stop, :restart, :status]
      action :nothing
    end

    template "/etc/init.d/#{identifier}" do
      source 'initd.erb'
      owner 'root'
      group 'root'
      mode 00755
      variables definition
      notifies :enable, "service[#{identifier}]"
      if definition['start']
        notifies :start, "service[#{identifier}]"
      end
    end

  # An upstart service.
  elsif definition['type'] == 'upstart'
    execute "start #{identifier}" do
      action :nothing
    end

    template "/etc/init/#{identifier}.conf" do
      source 'upstart.conf.erb'
      owner 'root'
      group 'root'
      mode 00644
      variables definition
      if definition['start']
        notifies :run, "execute[start #{identifier}]"
      end
    end

  # Invalid service type.
  else
    log "Allowed values for service type are: 'initd', 'upstart'." do
      level :error
    end
  end

  # --------------------------------------------------------------------------
  # Set up log rotation.
  # --------------------------------------------------------------------------

  if definition['log']['rotate']
    logrotate_app identifier do
      path definition['log']['path']
      frequency definition['log']['rotate']['frequency']
      rotate definition['log']['rotate']['rotate']
      options ['missingok', 'compress', 'notifempty']
    end
  end

  log "Completed service setup for #{identifier}."

end
