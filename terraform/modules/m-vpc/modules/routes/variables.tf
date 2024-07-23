variable "destination" {
  description = "The CIDR block for the destination traffic for the route."
}

variable "resource_id" {
  description = "The resource identifier for the specific target type.  Valid values here include internet gateway id, nat gateway id, transit gateway id, vpc endpoint id, and vpc peering connection id, specifically related to the value provided in target."
}

variable "route_table_id" {
  description = "The route table id to add the route to."
}

variable "target" {
  description = "The type of target for the route.  Value values here include igw, nat, tgw, vpce, and pcx."
}
