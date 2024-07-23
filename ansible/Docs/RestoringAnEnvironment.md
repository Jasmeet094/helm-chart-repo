### Steps to go from AWS backup, to fully funcitoning servers back in service.

1. Stop current instances which aren't functioning
1. Restore backup from aws backup
    * to do: screenshot and details around how exactly to do this
1. Update name and all other tags to be reflect past instance
1. TODO: Determine if hostname needs to be updated in etc/hostname and update this doc with that info
1. Update DNS for pvt entries with the appropriate private IP address
1. Replace the old with the new instances in the relevent target groups
1. TO DO: write documentation for this step
    * Update Nagios to look at the new servers 
    * Until this is done, Nagios will continue to send alerts for the wrong servers
    * This may be related to public DNS
