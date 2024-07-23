# Dev Workstation Setup

## Install saml2aws

[Install saml2aws](https://github.com/Versent/saml2aws#install)

```bash
saml2aws configure
```

```
Please choose a provier: `JumpCloud`
Please choose an MFA: `TOTP`
AWS Profile: `mhc`
URL: `https://sso.jumpcloud.com/saml2/aws-federated`
Username: `JumpCloud Username`
```

### `~/.saml2aws` config file

```bash
[mhc-prod]
name                    = mhc-prod
app_id                  =
url                     = https://sso.jumpcloud.com/saml2/aws-federated
username                = curtis@foghornconsulting.com
provider                = JumpCloud
mfa                     = TOTP
skip_verify             = false
timeout                 = 0
aws_urn                 = urn:amazon:webservices
aws_session_duration    = 43200
aws_profile             = mhc-prod
resource_id             =
subdomain               =
role_arn                = arn:aws:iam::913835907225:role/AdministratorAccess
region                  =
http_attempts_count     =
http_retry_delay        =
credentials_file        =
saml_cache              = false
saml_cache_file         =
target_url              =
disable_remember_device = false
disable_sessions        = false
prompter                =
```

## Authenticate CLI using saml2aws

```
saml2aws login -a mhc-prod
```

### Alias for container

```bash
alias mhc='saml2aws login -a mhc-prod'
alias mhcansible='saml2aws login -a mhc-prod && docker run --rm -it -e AWS_PROFILE=mhc-prod -v $HOME/foghorn/mhc/bash_history:/root/.bash_history -v $HOME/.ssh/mhc/mhc-ssh:/root/.ssh/id_rsa -v $HOME/.ssh/known_hosts:/root/.ssh/known_hosts:ro -v $HOME/.aws:/root/.aws -v $HOME/foghorn/mhc/c-mhc-operations:/data --entrypoint /bin/bash 913835907225.dkr.ecr.us-west-2.amazonaws.com/operations-ansible:latest'
```

## Get MHC Docker container

### Authenticate against Amazon ECR

```bash
aws ecr get-login-password \
 --region us-west-2 \
| docker login \
 --username AWS \
 --password-stdin 913835907225.dkr.ecr.us-west-2.amazonaws.com
```

### Pull Docker container

```bash
docker pull 913835907225.dkr.ecr.us-west-2.amazonaws.com/operations-ansible:latest
```
