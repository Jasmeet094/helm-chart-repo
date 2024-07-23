### LB Maintenance Script

For creating Jenkins job for it, just create an env and mode variable and use those to pass to positional args outlined in the help menu of the script.

Make sure AWS creds are exported into env for Jenkins job.

Make sure awscli is on Jenkins if not already there

If needing to update html, update html code and then manually create a rule on a listener and do a `aws elbv2 describe-rules --output json` to get proper formatting for it and update the message body field in the actions json.

Potential future improvement is moving script args from positional args to something like flags with getopts which could allow for additional overrides like specifying the aws region.


## Example for PROD 
*PROCEED WITH CAUTION*
./lb_maintenance.sh create Production-ALB1
./lb_maintenance.sh destroy Production-ALB1
