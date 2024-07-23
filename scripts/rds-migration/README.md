# Postgres RDS Migration

A collection of scripts for migrating Postgres data from EC2 to RDS. AWS DMS was initially explored, but we encountered several limitations that ultimately led us here.

## Script files

### `pg_dump.py`

Copy postgres data from a source to destination db.

### `validate_psql.py`

Validate that all the copied data matches between the source and destination db.

## Steps to execute scripts

1. Connect to the MHC vpn

1. SSH to ec2 db instance using ssh port forwarding

```bash
ssh -L 54321:localhost:7432 -L 54322:cctests01db-test.ctzs9xz2duaa.us-west-2.rds.amazonaws.com:6432 curtis@172.31.35.140

ssh -L 54321:localhost:7432 -L 54322:cctests01db.ctzs9xz2duaa.us-west-2.rds.amazonaws.com:6432 curtis@172.31.35.140


ssh -L 54321:localhost:7432 -L 54322:ps09db1.ctzs9xz2duaa.us-west-2.rds.amazonaws.com:6432 curtis@172.31.202.225
```

1. Update creds.yml with correct ec2/rds db passwords

1. Install script dependencies

```bash
pip install -r requirements.txt
```

1. Execute validate script

```bash
python3 <script>.py
```

## Connect to postgres

sudo su - postgres

psql -d djangostack -p 7432

psql -d djangostack -h <rds-endpoint-address> -p 6432

