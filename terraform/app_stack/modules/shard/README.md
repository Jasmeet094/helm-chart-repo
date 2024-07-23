A "shard" is the logical grouping of one or more each of a web instance and database instance.

The shard provides a Rout53 DNS alias to an Application load balancer (ALB), pointing to the webserver instance.

Requires:
  * Instance profiles named `WebServer` and `DBServer`
