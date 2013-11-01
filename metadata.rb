name              'forever-service'
maintainer        'Reason'
maintainer_email  'reason@exratione.com'
license           'MIT'
description       'Set up a service to run a designated Node.js script.'
version           '0.0.3'
recipe            'forever-service', 'Set up a service to run a designated Node.js script.'
recipe            'forever-service::upstart', 'Set up an upstart service definition.'
recipe            'forever-service::initd', 'Set up an init.d service definition.'
recipe            'forever-service::start', 'Start the service.'

depends 'nodejs'

%w{ fedora redhat centos amazon scientific oracle ubuntu debian }.each do |os|
  supports os
end

attribute 'forever-service/description',
  :display_name => 'Service Description',
  :description => 'A description for the service.',
  :required => 'required'

attribute 'forever-service/display-name',
  :display_name => 'Service Display Name',
  :description => 'The service name to display.',
  :required => 'required'

attribute 'forever-service/identifier',
  :display_name => 'Service Identifier',
  :description => 'The name used for the service definition file and other identifiers - so no spaces.',
  :required => 'required'

attribute 'forever-service/log-file-path',
  :display_name => 'Log File Path',
  :description => 'Absolute path to the log file for this service.',
  :required => 'required'

attribute 'forever-service/node-bin',
  :display_name => 'Node Binary Path',
  :description => 'Absolute path to the directory containing Node.js binaries.',
  :default => '/usr/local/bin'

attribute 'forever-service/node-path',
  :display_name => 'NODE_PATH Environment Value',
  :description => 'Absolute path to the node modules directory.',
  :default => '/usr/local/lib/node_modules'

attribute 'forever-service/pid-file-path',
  :display_name => 'Process ID File Path',
  :description => 'Path to the file containing the service process ID, e.g. /var/run/myservice.pid.',
  :required => 'required'

attribute 'forever-service/service-type',
  :display_name => 'Service Type',
  :description => 'The type of service to set up, init.d or upstart.',
  :default => 'initd'

attribute 'forever-service/start-script',
  :display_name => 'Service Start Script',
  :description => 'Absolute path to the Node.js script to launch the service process.',
  :required => 'required'

attribute 'forever-service/start-service',
  :display_name => 'Start the Service?',
  :description => 'If set then launch the service, otherwise just create it.'

# Note that the service launches as root regardless of what is specified as the
# user here.
#
# It is the responsibility of the Node.js script to switch to using the declared
# user after binding to privileged ports, etc.
#
# We need to know that user here so that we can set up the log directory with
# the right ownership.
attribute 'forever-service/user',
  :display_name => 'Service User',
  :description => 'User who runs the service and owns the log directory.',
  :default => 'root'

attribute 'forever-service/forever/min-uptime',
  :display_name => 'Forever Option: minUptime',
  :description => 'Minimum uptime in milliseconds for a script to not be considered "spinning."',
  :default => '5000'

attribute 'forever-service/forever/spin-sleep-time',
  :display_name => 'Forever Option: spinSleepTime',
  :description => 'Time to wait in milliseconds between launches of a spinning script.',
  :default => '2000'
