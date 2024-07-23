# Adding a new shard to Nagios

How-to for adding new instances/shards to nagios monitoring service.

## SSH to ssmon01

1. SSH to `ssmon01pvt.mobilehealthconsumer.com` (nagios monitoring server)
while connected to the MHC VPN using your jumpcloud credentials.

## Nagios configuration

1. All nagios config files are located in `/usr/local/nagios/etc`.

## Add new devices

1. Create or copy an environment `.cfg` file in `/usr/local/nagios/etc/objects/devices/`
to a new file/folder that makes sense based on the environment of the instance/shard.

1. Next, update the config file with the instance names and DNS addresses.

1. For example, to add the `ps14` shard. Create a new file `ps14.cfg` in
`devices/prod` dir since this is a production shard.

1. There should be a `define host{}` block for each instance in the shard.

`Note: db hosts are slightly different than admin/web hosts.`

### Example: ps14.cfg

#### Admin/Web host

```bash
define host{
        use                     generic-host
        host_name               ps14w1.mobilehealthconsumer.com
        alias                   ps14w1.mobilehealthconsumer.com
        address                 ps14w1pvt.mobilehealthconsumer.com
        action_url              http://ps14w1.mobilehealthconsumer.com/partners/login
        _instanceid             i-001c3fd190a1b4d6e
        _instanceregion         us-west-2
        _dns   ps14w1pvt.mobilehealthconsumer.com
        }
```

#### DB host

```bash
define host{
        use                     generic-host
        host_name               ps14db1.mobilehealthconsumer.com
        alias                   ps14db1.mobilehealthconsumer.com
        address                 ps14db1pvt.mobilehealthconsumer.com
        _instanceid             i-09d26864815e5f245
        _instanceregion         us-west-2
        _STUNNEL                27222
        }
```

1. Ensure the hostnames and dns addresses are accurate.

`Note: I believe the instance ID and vol IDs are no longer necessary.`

## Add new hostgroups

1. To add a new type of environment aka a different prefix make the following changes

   1. in `/usr/local/nagios/etc/objects/hostgroups.cfg` add the following items

      ```bash
      define hostgroup {
        hostgroup_name          S_Servers
        hostgroup_members       S_Database_Servers,S_Web_Servers
      }

      define hostgroup {
        hostgroup_name          S_Database_Servers
        members                 ^s[a-z](s[0-9][0-9]|log)db[0-9].*com$
      }

      define hostgroup {
        hostgroup_name          S_Web_Servers
        members                 ^s[a-z](s[0-9][0-9]|log)w[0-9].*com$
      }

      define hostgroup{
        hostgroup_name       S_App_Loadbalancers
        members               ^S[A-Z]-ALB.*$
      }
      ```

1. Search for `nonprod-databases`, `nonprod-webservers`, and `nonprod-loadbalancer_app`
add the groups into there.

## Validate nagios config

1. Run the following to verify configuration data

   ```bash
   /usr/local/nagios/bin/nagios -vvv /usr/local/nagios/etc/nagios.cfg
   ```

## Restart nagios & validate logs

1. After config changes restart the nagios service

   ```bash
   sudo systemctl reload nagios
   ```

1. Verify nagios service status

   ```bash
   sudo systemctl status nagios
   ```

1. Verify nagios logs

   ```bash
   sudo journalctl -xefu nagios
   ```

For information on what instance checks are performed, see [Nagios Overview](./Overview.md)
