
# The type of service to install.
default['forever-service']['type'] = 'initd'

# User that will be running the service, but here is only important to determine
# ownership of the log directory.
default['forever-service']['user'] = 'root'

# Default values for building Node.js from source with no special settings
# used for the make install step.
default['forever-service']['node-bin'] = '/usr/local/bin'
default['forever-service']['node-path'] = '/usr/local/lib/node_modules'

# If set to anything truthy then start the service as well as creating it.
default['forever-service']['start-service'] = false

# Forever process setting defaults.
default['forever-service']['forever']['min-uptime'] = 5000
default['forever-service']['forever']['spin-sleep-time'] = 2000
