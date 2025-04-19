# Role definition for installing [cert-manager](https://cert-manager.io/).

```
├── roles
│  ├── cert-manager-install
|  |  ├── defaults
|  |  |  ├── main.yml
|  |  ├── tasks
|  |  |  ├── main.yml 
|  |  |  ├── setup-aws-env.yml
|  |  |  ├── setup-route53-ddns.yml
|  |  |  ├── setup-self-signed-ca.yml
|  |  |  ├── setup-lets-encrypt-ca.yml  
|  |  ├── templates
|  |  |  ├── self-signed-ca.yml.j2
|  |  |  ├── lets-encrypt-ca.yml.j2
|  |  |  ├── route53-ddns.sh.j2
|  |  |  ├── route53-ddns-policy.json.j2
```

This structure houses the [Ansible Role](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html#roles) for installing the [cert-manager](https://cert-manager.io/) package, which automates the management, issuance, and renewal of TLS certificates.
It adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates. 
It works with multiple certificate issuers, including Let's Encrypt, self-signed certificates, and internal PKI authorities.

In a K3s cluster, cert-manager integrates seamlessly with Traefik, enabling automatic TLS for Ingress resources.

![Certificate Management](cert-management.svg)

## Synopsis

This role does the following:

1. Creates a namespace for the cert-manager deployment.
2. Deploys the [cert-manager Helm chart](https://cert-manager.io/docs/installation/helm/).
3. Configures the CRD's for:
   - The Self-Signed Issuer
   - Certificate and ClusterIssuer for the Private CA for use with the Local Domain.
   - Certificate and ClusterIssuer for the Public CA using Let's Encrypt for use with the Public Domain.
4. Configures Route53 DDNS
   - Configure the AWS environment for Route53 DNS updates.
   - Creates a managed IAM policy for the Route53 DDNS updates and attaches it to the IAM user.
   - Generates a script and cronjob to update Route53 DNS records.
5. Configures a Route53 DNS solver for the `Let's Encrypt` ACME challenge.
  
## Configuration

Configure the namespace for the cert-manager deployment via the variable `k3s_cert_manager_namespace`:
```yaml
k3s_cert_manager_namespace: cert-manager-system
```

Configure enabling the self-signed CA for ingress via local domain:
```yaml
enable_selfsigned: true
```
Configure the name of the CA for self-signed certificates with the variable `private_ca`:
```yaml
private_ca: "k3s-ca"
```

Configure the naming of the CA for public certificates issued by `Let's Encrypt` via the variable `public_ca`:
```yaml
public_ca: "letsencrypt"
```

Configure enabling the `Let's Encrypt` ACME (Automated Certificate Management Environment) as a TLS issuer for public domain
```yaml
enable_letsencrypt: false
```
Configure the email address for Let's Encrypt certificate issuance via the variable `email`. 
```yaml
email: your_email@mail.com
```   
Let's Encrypt will use this to contact you about expiring certificates and issues related to your account.
      
Configure enabling AWS's Route53 DNS for the `Let's Encrypt` ACME challenge if your public domain is managed by AWS Route53:
```yaml
enable_route53: false
```
   
Configure the log file location for the Route53 DDNS script via the variable `cron_log_file`:
```yaml
cron_log_file: "/var/log/update_route53_ddns.log"
```

### Route53    
        
#### AWS Environment Configuration

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
                                                                                                        
#### Bootstrapping the IAM User

The playbook will attach the appropriate IAM policies to affect Route53 DDNS updates, however, the user should be bootstrapped with the `IAMReadOnlyAccess` and `IAMFullAccess` policies *to be able* to 
attach the policies for updating Route53 DNS records.

These policies (`IAMReadOnlyAccess` and `IAMFullAccess`) can be removed after the playbook has been run.

## Exporting and Trusting the Self-Signed CA Certificate

If you enabled the self-signed CA, it will automatically be exported and trusted on the `control_plane`. If you want to export the CA certificate to your local machine, 
you can find it at `/usr/local/share/ca-certificates/k3s-ca-cert.crt` on the DeskPi acting as the `control_plane`.

To trust the CA certificate on your local machine, do the following:

###### On Linux:
```shell
sudo cp k3s-ca.crt /usr/local/share/ca-certificates/k3s-ca-cert.crt
sudo update-ca-certificates
```

###### On Mac:
```shell
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain k3s-ca-cert.crt
```

###### On Windows:
- Open **certmgr.msc**
- Go to **Trusted Root Certification Authorities** → **Certificates**
- Right-click → **Import** → Select **k3s-ca-cert.crt**
   
## Logging

The Route53 DDNS script will log to the file specified in the variable `cron_log_file` (default: `/var/log/update_route53_ddns.log`). 
Logs are rotated daily, compressed and archived for a week.

## Testing

Verify the installation by running the command:

```shell
kubectl get pods -n cert-manager-system
```

You should see three pods running in the `cert-manager-system` namespace:

```shell
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-7f9d96d7b8-xyzxx              1/1     Running   0          1m
cert-manager-cainjector-5ff6c59d4b-kjxxm   1/1     Running   0          1m
cert-manager-webhook-6b5b5f65c8-xjzkk      1/1     Running   0          1m
```

### Route53

There is a playbook available in the [tests](tests/test-route53-ddns-script-gen.yml) directory with which you can test the generation of the `route53-ddns.sh` file,
run the following command from the project root directory:

```shell
ansible-playbook roles/cert-manager-install/tests/test-route53-ddns-script-gen.yml
```
                                           
To test the policy assignment of the [IAM policy](tests/test-route53-ddns-policy.yml) for Route53 DDNS updates run the following command from the project root directory:
```shell
ansible-playbook roles/cert-manager-install/tests/test-route53-ddns-policy.yml
```

To clean up resources created by the tests, run the following command:

```shell
ansible-playbook roles/cert-manager-install/tests/cleanup.yml
```

To check that the Route53 records are correctly updated you can use either the AWS CLI or a DNS query to check what’s actually recorded.

#### 1. Using AWS CLI:

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

#### 2. Using DNS Query:

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

## Troubleshooting issues with Certificates
                    
If you are having issues with certificates or the certificate issuers, you can try the following steps:

##### 1. Check the logs of the `cert-manager` pods

```shell
kubectl logs deployment/cert-manager -n <cert-manager-namespace>
```

##### 2. Describe the Issuers and Certificates
```shell
kubectl describe clusterissuer <issuer-name>
```                                                              

```shell
kubectl describe certificate <certificate-name> -n <namespace>
```

##### 3. Check the Active Challenges

List them:
```
kubectl get certificaterequests -A
kubectl get orders -A
kubectl get challenges -A
```
Then describe one:
```shell
kubectl describe certificaterequest <name> -n <namespace>
kubectl describe order <name> -n <namespace>
kubectl describe challenge <name> -n <namespace>
```
That could reveal which part of the DNS-01 validation or ACME process is failing.

## References

https://cert-manager.io/docs/installation/helm/
https://picluster.ricsanfre.com/docs/certmanager/
