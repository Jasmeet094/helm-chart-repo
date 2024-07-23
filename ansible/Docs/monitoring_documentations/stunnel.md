# STunnel
## Setup
Each environment is setup for a range of ports 27\d\d[0-9]
Production I moved to its own range 2721x and will go as high as we need
## new shard
1. Setup stunnel connects to db server in /etc/stunnel/mhc.conf
'''bash

######
### XX
######
[{DNSRECORD (PUBLIC)}.mobilehealthconsumer.com]
client = yes
accept = 127.0.0.1:{PORT_ON_LOCALBOX}
connect = {PVTRecords}.mobilehealthconsumer.com:27027

Therefore

######
### PT
######
[pts01db1.mobilehealthconsumer.com]
client = yes
accept = 127.0.0.1:27101
connect = pts01db1pvt.mobilehealthconsumer.com:27027

'''
1. when setting up a new node put that 
'''bash
define host{
        use                     generic-host
        host_name               pts01db1.mobilehealthconsumer.com
        alias                   pts01db1.mobilehealthconsumer.com
        address                 pts01db1.mobhealthinternal.com
        _instanceid             i-0165375fbbe38ad71
        _instanceregion         us-west-2
	    _STUNNEL                27101 # this is what we put above
}

'''