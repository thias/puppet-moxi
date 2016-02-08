# puppet-moxi

## Overview

Install, enable and configure moxi, the persistent connection proxy used with
CouchBase. Currently works for Red Hat Enterprise Linux, possibly others with
minor changes.

* `moxi` : Main class to manage moxi-server.

Note that for RHEL7+ this module will require the `thias-rhel` module in
order to manage an improved systemd service.

## Examples

```puppet
class { '::moxi':
  options     => '-t 8 -c 4096 -s /opt/moxi/moxi.sock -a 0777 -v -O /opt/moxi/moxi.log',
  cluster_url => 'http://192.168.1.1:8091/pools/default/bucketsStreaming/default|http://192.168.1.2:8091/pools/default/bucketsStreaming/default',
}
```

