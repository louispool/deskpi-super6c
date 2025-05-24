# Role definition for setting up Dynamic DNS for [AWS Route53](https://aws.amazon.com/route53/)
```
├── roles
│  ├── route53-ddns-install
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks
|  |  |  ├── main.yml 
|  |  |  ├── setup-aws-env.yml
|  |  |  ├── setup-route53-ddns.yml
|  |  ├── templates
|  |  |  ├── route53-ddns.sh.j2
|  |  |  ├── route53-iam-policy.json.j2
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for setting up Dynamic DNS for [AWS Route53](https://aws.amazon.com/route53/).

## Synopsis

This role does the following:

1. Configures the AWS environment for Route53 DNS updates.
2. Creates a managed IAM policy for the Route53 DDNS updates and attaches it to the IAM user.
3. Generates a script and cronjob to update Route53 DNS records.
                                                                
## Configuration

Configure enabling AWS's Route53 DNS for the `Let's Encrypt` ACME challenge if your public domain is managed by AWS Route53:
```yaml
enable_route53: false
```
      
Configure whether IPv6 addresses should be supported via the variable `update_ipv6`:
```yaml
IPv6_enabled: true
```

Configure the list of public sub-domains to register with the Route53 DNS server:
```yaml
public_domains:
  - "k3s.example.com"
```

Configure the log file location for the Route53 DDNS script via the variable `cron_log_file`:
```yaml
cron_log_file: "/var/log/update_route53_ddns.log"
```

When using Route53 you will also need to configure the AWS environment.
```yaml
# The AWS Access Key ID and Secret Access Key for the IAM user that will be used to update the Route53 DNS records:
aws_access_key_id:
aws_secret_access_key:
aws_region:

# The AWS Hosted Zone ID.
aws_hosted_zone_id:

# Your AWS account ID (e.g. "005162895111")
aws_account_id:
# IAM username (e.g. "myuser" from `arn:aws:iam::<account-id>:user/myuser`)
aws_iam_user:
```

Consider using Ansible Vault to store these variables securely.

## Bootstrapping the IAM User

The playbook will attach the appropriate IAM policies to affect Route53 DDNS updates, however, the user should be bootstrapped with the `IAMReadOnlyAccess` and `IAMFullAccess` policies *to be able* to
attach the policies for updating Route53 DNS records.

The policy `IAMFullAccess` can be removed after the playbook has been run, however, the `IAMReadOnlyAccess` policy is still required for the IAM user to be able to list policies in future executions of this role.

## Logging

The Route53 DDNS script will log to the file specified in the variable `cron_log_file` (default: `/var/log/update_route53_ddns.log`).
Logs are rotated daily, compressed and archived for a week.

## Testing

There is a playbook available in the [tests](../route53-ddns-install/tests/test-route53-ddns-script-gen.yml) directory with which you can test the generation of the `route53-ddns.sh` file,
run the following command from the project root directory:
```shell
ansible-playbook roles/route53-ddns-install/tests/test-route53-ddns-script-gen.yml
```

To test the policy assignment of the [IAM policy](../route53-ddns-install/tests/test-route53-ddns-policy.yml) for Route53 DDNS updates run the following command from the project root directory:
```shell
ansible-playbook roles/route53-ddns-install/tests/test-route53-ddns-policy.yml
```

To clean up resources created by the tests, run the following command:
```shell
ansible-playbook roles/route53-ddns-install/tests/cleanup.yml
```
   
## Verifying Route53 DNS Updates

To check that the Route53 records are correctly updated you can either use the AWS CLI or a DNS query to check what’s actually recorded.

### 1. Using AWS CLI:

To list the records in your hosted zone:
```shell
aws route53 list-resource-record-sets --hosted-zone-id YOUR_HOSTED_ZONE_ID
```

This will dump all the records — filter the ones you care about:
```shell
aws route53 list-resource-record-sets --hosted-zone-id YOUR_HOSTED_ZONE_ID --query "ResourceRecordSets[?Name == 'example.com.']"
```

Replace `example.com.` with your record (note the trailing dot — DNS absolute FQDN format).

You can also look for your AAAA record if needed:
```
--query "ResourceRecordSets[?Name == 'example.com.' && Type=='AAAA']"
```  

### 2. Using DNS Query:

Sometimes Route53 changes propagate quickly, sometimes it takes a moment — but you can check what’s resolving publicly:
```shell
dig +short example.com
dig +short AAAA example.com
```

Or specify a DNS resolver if your local cache is in the way:
```shell
dig @8.8.8.8 +short example.com
```

This should return the IP address the DDNS script pushed.