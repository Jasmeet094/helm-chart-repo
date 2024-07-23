#!/bin/bash
 mongo --eval "db.adminCommand( { setFeatureCompatibilityVersion: \"$1\" } )"