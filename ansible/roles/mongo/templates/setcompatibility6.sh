# Set MongoDB compatibility version to 6.0

#!/bin/bash
 mongosh --eval "db.adminCommand( { setFeatureCompatibilityVersion: \"$1\" } )"