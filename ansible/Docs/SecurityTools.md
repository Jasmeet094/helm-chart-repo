## What is OSSEC
MHC Servers use the OSSEC tool in order serve as the Host Based Intrusion Detection system. It performs log analysis, checksum change checking, rootkit detection, and can report out important messages via email.

## Why is it used?
In addtion to providing value to MHC's security posture, having a mechanism in place that can show documentation with proof that checks are actively happening is a requirement of Hitrust, and is thus of utmost importance. Having it complete during Q2 is essential.

## How is it configured?
There is a role to install/configure the OSSEC agent. 
This role is called upon via the update_ossec.yml playbook, when using the ossec tag.

It is setup to be run in the local server settting.

