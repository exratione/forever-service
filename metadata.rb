name              'forever-service'
maintainer        'Reason'
maintainer_email  'reason@exratione.com'
license           'MIT'
description       'Set up one or more services to run designated Node.js scripts under the Forever process manager.'
version           '0.0.5'
recipe            'forever-service', 'Set up services to run designated Node.js scripts.'

depends 'n-and-nodejs'
depends 'logrotate'

%w{ fedora redhat centos amazon scientific oracle ubuntu debian }.each do |os|
  supports os
end

attribute 'forever-service/forever/version',
  :display_name => 'Forever version',
  :description => 'Version of the Forever process manager to install.',
  :default => '0.11.1'

attribute 'forever-service/node/bin',
  :display_name => 'Node binary path',
  :description => 'Absolute path to the directory containing Node.js binaries.',
  :default => '/usr/local/bin'

attribute 'forever-service/node/path',
  :display_name => 'NODE_PATH value',
  :description => 'Absolute path to the node modules directory.',
  :default => '/usr/local/lib/node_modules'

attribute 'forever-service/services',
  :display_name => 'Services.',
  :description => 'Defining parameters for each service to be created.',
  :required => 'required',
  :type => 'hash'
