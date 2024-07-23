# Terraform for AWS WAF

Parameterize account-specific variables and backend using `tfvars`:

```
ENV=dev-tf-auto
rm -r .terraform/
terraform init -backend-config=${ENV}/backend.tfvars
terraform workspace select $ENV
terraform plan -var-file=${ENV}/vars.tfvars
```

This should result in allowing XSS content to the paths defined in `allowed_rules.tf`, and inhibiting XSS to any other paths. Test this with:

```
curl -X POST http://waftest.example.com/?'%3Cscript%3Ealert(0)%3C/script%3E'
curl -X POST http://waftest.example.com/?'<script>alert(0)</script>'
curl -X POST http://waftest.example.com/partners/partner/updateIncentive?'%3Cscript%3Ealert(0)%3C/script%3E'
curl -X POST http://waftest.example.com/partners/partner/updateIncentive?'<script>alert(0)</script>'
curl -X POST http://waftest.example.com/data?'<script>alert(0)</script>'
```

Additionally, the Cloudwatch notifications `waf_allowed_notification` and `waf_blocked_notification` will fire in either case, and email whomever is on the SNS distro.

## Updates and Destroy

Terraform for AWS WAF is a bit buggy. Changing existing WAF rule priority never seems to work, and `destroy` usually fails partway through, as Terraform doesn't seem to handle AWS WAF dependencies correctly (rules cannot be deleted if they're not empty, etc.). You will likely need to manually edit the WAFs in the AWS console, when trying to update (`apply` changes) or `destroy` these resources.

# Route 53 DNS

Since Cloudfront takes a long time to create, the Route 53 updates are in a separate subfolder, so that they can be run separately, after Cloudfront is finished updating. This isn't ideal (we'd like Terraform to wait for Cloudfront to finish deploying and then just update Route 53 at that point), but is a limitation of Terraform.

    cd route53
    terraform init -backend-config=backend_${ENV}.tfvars
    terraform plan -var-file=${ENV}.tfvars

**Note** that we depend on there already being a Route 53 entry for `<subdomain>origin.<root_domain>`. This DNS entry is an MHC conventions, but the WAF configuration here does not enforce it nor check that it is valid. *You have been warned.*

## Allowed Routes
The legitimate use that might be flagged as cross-script scripting all involve admin screens that support editing an HTML fragment. In Incapsula, cross-site scripting is blocked in QA with some of the above URIs being whitelisted.

/partners/partner/clients/
/partners/partner/configureResource/
/partners/partners/configureEmail/
/partners/partner/configureIncentive/
/partners/partners/configureMessage/
/partners/partner/configureReimbursementPlan/
/partners/partner/configureClientCareGap
/partners/partner/configureSection/
/partners/partner/configureTile
/partners/partner/getChallengeCourseInfo/
/partners/partner/updateIncentive/
/partners/partner/updateMessage/
/partners/partner/updateResource/

# https://github.com/terraform-providers/terraform-provider-aws/issues/534
