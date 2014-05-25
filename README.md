# Node.js Forever Service Cookbook

This Chef cookbook sets up an Upstart or /etc/init.d service definition for one
or more Node.js scripts using the [Forever][0] service manager. Forever is
configured to restart each Node.js process should it ever fail.

## Cookbook Dependencies

This depends on the following cookbooks:

  * logrotate
  * n-and-nodejs

Note the use of [n-and-nodejs][1] rather than the more commonly used [nodejs][2]
cookbook. If using [Librarian-chef][3] to manage dependences, then include these
custom cookbooks in the project Cheffile as follows:

```
cookbook 'n-and-nodejs',
  :git => 'https://github.com/exratione/n-and-nodejs-cookbook',
  :ref => 'v0.0.2'

cookbook 'forever-service',
  :git => 'https://github.com/exratione/forever-service',
  :ref => 'v0.0.5'
```

## Usage

Include this cookbook in the Chef runlist after the installation of Node.js and
its dependencies:

```
run_list [
  'recipe[build-essential]',
  'recipe[curl]',
  'recipe[n-and-nodejs]',
  'recipe[forever-service]'
]
```

## Attributes

The example attributes below define two services running from the same script,
which is a common use case for a Node.js server application. Multiple running
processes improve redundancy and take advantage of the existence of multiple
processors.

Sane use of Forever requires that all concurrently running processes have unique
paths, so symlinks to the single Node.js script are used. If the processes have
to bind to one or more ports or take other distinct actions, then the Node.js
script can examine the unique symlink path used to invoke it and determine the
configuration it should use. For example, a script `server.js` might be
symlinked from `server-a.js`, `server-b.js`, and `server-c.js`, and from that
know that it must read from configuration file `a.json`, `b.json`, or `c.json`.

```
default_attributes(
  'forever-service' => {
    'forever' => {
      # Set which version of the Forever package is installed globally via NPM.
      'version' => '0.11.1'
    },
    'node' => {
      # This is added to the PATH environment variable in the service scripts.
      # It is the directory in which the node binary resides for a standard
      # installation.
      'bin' => '/usr/local/bin',
      # Used to set the NODE_PATH environment variable in the service scripts.
      'path' => '/usr/local/lib/node_modules',
    },
    'services' => {
      # The key 'nodejs-server-1' will be used as the service identifier.
      'nodejs-server-1' => {
        # A service description. If omitted this defaults to the service
        # identifier.
        'description' => 'Node.js server process 1.',
        # A service display name. If omitted this defaults to the service
        # identifier.
        'display_name' => 'Node.js Server 1',
        # If enable is set to false, this definition will not be used. This can
        # be useful in some more advanced uses of Chef wherein attributes are
        # layered and merged from different sources.
        'enable' => true,
        # Configuration used when invoking Forever in service scripts.
        'forever' => {
          # These two help prevent servers from thrashing if they fail
          # immediately on launch. See the Forever documentation for more
          # details.
          'min_uptime' => 5000,
          'spin_sleep_time' => 2000
        },
        # Logging configuration.
        'log' => {
          # Absolute path to the log file.
          'path' => '/var/log/node/server-1.log',
          # Set this to false if you don't want log rotation set up.
          'rotate' => {
            # The standard values for these logrotate configuration parameters
            # are accepted. They pass through to the logrotate cookbook.
            'frequency' => 'weekly',
            'rotate' => 52
          }
        },
        # Absolute path to the pidfile created by Forever.
        'pid_file_path' => '/var/run/node-server-1.pid',
        # Absolute path to the application start script.
        'start_script' => '/path/to/scripts/server.js',
        # Absolute path for a symlink to the application start script. This will
        # be created if not present. This attribute can be omitted, but note
        # that this usage of Forever requires that all services have unique
        # start script paths. When running multiple services from the same
        # script it is necessary to use symlinks to provide those unique paths.
        'start_script_symlink' => '/path/to/scripts/server-1.js',
        # If true start the service in the provisioning process, otherwise leave
        # it unstarted. This defaults to true if omitted.
        'start' => true,
        # Allowed values are 'upstart' and 'initd', defining which type of
        # service is set up.
        'type' => 'initd',
        # The name of the user that the service runs under. The service will
        # always launch as root, but it is expected that it will downgrade its
        # permissions run as this user.
        'user' => 'node'
      },
      # This is a clone of the service definition above, replacing 1 with 2
      # in the attributes where appropriate. See the comments above.
      'nodejs-server-2' => {
        'description' => 'Node.js server process 2.',
        'display_name' => 'Node.js Server 2',
        'enable' => true,
        'forever' => {
          'min_uptime' => 5000,
          'spin_sleep_time' => 2000
        },
        'log' => {
          'path' => '/var/log/node/server-2.log',
          'rotate' => {
            'frequency' => 'weekly',
            'rotate' => 52
          }
        },
        'pid_file_path' => '/var/run/node-server-2.pid',
        'start_script' => '/path/to/scripts/server.js',
        'start_script_symlink' => '/path/to/scripts/server-2.js',
        'start' => true,
        'type' => 'initd',
        'user' => 'node'
      }
    }
  },
  # The n-and-nodejs cookbook values.
  'n-and-nodejs' => {
    'n' => {
      'version' => '1.2.1'
    },
    'nodejs' => {
      'version' => 'stable'
    }
  }
)
```

## Upstart or Init.d

Choose which service type to set up for each service defined by setting the
`forever-service['SERVICE-IDENTIFIER']['type']` attribute to either `upstart` or
`initd`.

The init.d script template used here should work just fine in both RPM-based and
Debian-based distributions. The Upstart script requires Upstart to be present,
which is not the case for all Linux distributions.

## Service User and Permissions

The service launches the Node.js process as the root user. It is expected that
the Node.js script will downgrade permissions to the user specified in the
attributes after binding to privileged ports or performing whatever other
activities require root permissions. For example this is done as follows for
the `node` user:

```
process.setgid('node');
process.setuid('node');
```

This cookbook needs to know about the service user and create the user if it
doesn't already exist in order to correctly set up ownership and permissions
for the service log directory.

[0]: https://github.com/nodejitsu/forever
[1]: https://github.com/exratione/n-and-nodejs-cookbook
[2]: https://github.com/mdxp/nodejs-cookbook
[3]: https://github.com/applicationsonline/librarian-chef
