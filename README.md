Node.js Forever Service Cookbook
================================

This Chef cookbook sets up an Upstart or /etc/init.d service definition to run a
Node.js script using the [Forever][0] service manager.

Include the recipes from this cookbook in your runlist after the installation of
Node.js:

```
run_list [
  'recipe[nodejs]',
  'recipe[forever-service]'
  'recipe[forever-service::start]'
]
```

Upstart or Init.d
-----------------

Choose which service type to set up by setting the
`forever-service['service-type']` attribute to either "upstart" or "initd".

The init.d script used here should work just fine in both RPM-based and
Debian-based distributions. The Upstart script requires that you have Upstart
installed in your system, as is the case if you are using Ubuntu.

Attributes
----------

  * `forever-service['description']` = Description of the service.
  * `forever-service['display-name']` = Service display name.
  * `forever-service['identifier']` = Service name used for files and service calls.
  * `forever-service['log-file-path']` = Absolute path to the log file.
  * `forever-service['node-bin']` = Path to the directory containing the node binary.
  * `forever-service['node-path']` = Path to the directory containing node modules.
  * `forever-service['pid-file-path']` = Path to the service process pidfile.
  * `forever-service['service-type']` = "initd" or "upstart".
  * `forever-service['start-script']` = Path to the Node.js script to run under Forever.
  * `forever-service['user']` = The user that the process will ultimately run under.

Further, there are attributes to set values for some of the Forever process
manager options. See the [Forever documentation][0]
for information on these.

  * `forever-service['forever']['min-uptime']`
  * `forever-service['forever']['spin-sleep-time']`

Attributes Example
------------------

```
default_attributes(
  'forever-service' => {
    'description' => 'A Node.js server.',
    'display-name' => 'Node.js Server ',
    'identifier' => 'nodejs-server',
    'log-file-path' => '/var/log/node/server.log',
    'node-bin' => '/usr/local/bin',
    'node-path' => '/usr/local/lib/node_modules',
    'pid-file-path' => '/var/run/angular-websocket-transport.pid',
    'service-type' => 'initd',
    'start-script' => '/home/node/project/src/server.js',
    'user' => 'node',
    'forever' => {
      'min-uptime' => 5000,
      'spin-sleep-time' => 2000
    }
  }
)
```

Service User and Permissions
----------------------------

The service launches the process as root. It is expected that the Node.js script
will downgrade permissions to another user and group appropriately after binding
to priviledged ports, or performing whatever other activities require root
permissions. e.g.:

```
process.setgid('node');
process.setuid('node');
```

This cookbook only needs to know the user (and create it if it doesn't already
exist) in order to correctly set up the log file and directory.

[0]: https://github.com/nodejitsu/forever
