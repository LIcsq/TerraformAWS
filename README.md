# AWS WordPress Setup

This project sets up an AWS infrastructure for a WordPress application using Terraform and deploys WordPress to an EC2 instance. It aims to simplify the deployment process by automating the creation of required AWS resources and configuring WordPress.

## Infrastructure

The following resources are created:
- VPC with public and private subnets
- MySQL RDS instance (private)
- ElastiCache-Redis instance (private)
- EC2 instance (public via ELB)
- Elastic Load Balancer (ELB)

## Project Structure

```bash
WordPress/
├── modules/
│   ├── ec2/
│   ├── elb/
│   ├── elasticache/
│   ├── rds/
│   ├── security_group/
│   └── vpc/
├── wordpress_conf/
│   ├── install_wordpress.sh
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
```

## Configuration

The MySQL RDS and ElastiCache-Redis endpoints and credentials are passed to WordPress via environment variables.

## Deployment

The application is deployed automatically using a user data script in the EC2 instance.

## Installation Instructions

### Prerequisites

- **Terraform**: Install Terraform from [Terraform Downloads](https://www.terraform.io/downloads.html).
- **AWS CLI**: Install and configure AWS CLI with your AWS credentials.[AWS Downloads](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Vault**: Ensure Vault is installed and running.[Vault Downloads](https://developer.hashicorp.com/vault/install)

### Initializing and Unsealing Vault

Follow the instructions in the Vault documentation to initialize and unseal your Vault server:
[Initializing and Unsealing Vault](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-deploy)

### Storing Credentials in Vault

To store your database credentials in Vault, use the following command:
```sh
vault kv put secret/db_credentials db_name="wordpress" db_username="wordpress_user" db_password="wordpress_password"
```

### AWS CLI Configuration

To configure the AWS CLI, run the following command and provide your AWS access key, secret key, region, and output format:
How to get creds look [here](https://blog.purestorage.com/purely-educational/how-to-use-aws-iam-with-terraform/)

```sh
aws configure
```
    
## Setup

1. **Clone the Repository**:
    ```sh
    git clone https://github.com/LIcsq/TerrafromAWS.git
    cd TerrafromAWS
    ```

2. **Setup Vault**:
   
   Export vault token:
    ```sh
    export VAULT_TOKEN=YOUR-TOKEN
    ```
    
   Export vault ip addres:
    ```sh
    export VAULT_ADDR='YOUR_IP'
    ```
    
    To store your database credentials in Vault, use the following command:
    ```sh
    vault kv put secret/db_credentials db_name="wordpress" db_username="wordpress_user" db_password="wordpre
    ```
    
4. **Initialize Terraform**:
    ```sh
    terraform init
    ```

5. **Apply Terraform Configuration**:
    ```sh
    terraform apply -auto-approve
    ```

### Accessing WordPress

Once the setup is complete, you can access the WordPress instance using the public IP address of the EC2 instance. You can find the public IP address in the Terraform output.

## Configuration Options

Terraform Module Variables

```sh
    project_name: Name of the project.
    default_tags: Default tags to apply to resources.
    cidr_block: CIDR block for the VPC.
    public_subnet_cidr: List of CIDR blocks for public subnets.
    private_subnet_cidr: List of CIDR blocks for private subnets.
    availability_zones: List of availability zones for subnets.
```

## Customization

To customize the configuration, modify the variables.tf file and update the values as needed. For example, to change the project name:

variables.tf:
```sh
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "your_custom_project_name"
}
```

Update the corresponding variable in main.tf:
```sh
module "rds" {
  source            = "./modules/rds"
  subnet_ids        = module.vpc.private_subnet_ids
  db_name           = data.vault_kv_secret_v2.db_credentials.data["db_name"]
  username          = data.vault_kv_secret_v2.db_credentials.data["db_username"]
  password          = data.vault_kv_secret_v2.db_credentials.data["db_password"]
  security_group_id = module.security_group.rds_security_group_id
  project_name      = var.project_name
  default_tags      = var.default_tags
}
```

## Troubleshooting Tips and Common Issues

### AWS Credentials

Ensure your AWS credentials are correctly configured. You can verify this by running:

```sh
aws sts get-caller-identity
```

### Terraform Errors

Check the Terraform output for any errors. Common issues include incorrect variable values and insufficient AWS permissions.
EC2 Instance Access

If you cannot access the WordPress instance:

   - Ensure the security group allows inbound traffic on port 80 (HTTP) from ELB.
   - Check the healt status of target group.

### Vault Issues

If Vault secrets are not being fetched correctly:

- Ensure the Vault token is correctly exported.
- Verify the Vault server address and token by running:

```sh
vault status
vault token lookup
```


## Potential Improvements

   - **High Availability**: Implement high availability for RDS and ElastiCache.
   - **Autoscaling**: Configure autoscaling for the EC2 instance.
   - **Monitoring and Logging**: Integrate AWS CloudWatch for monitoring and logging.
   - **Backup and Recovery**: Set up automated backups for RDS and regular snapshots for the EC2 instance.
    
## Contributing

I am welcome contributions to this project. To contribute:

   1. Fork the repository.
   2. Create a new branch (git checkout -b feature-branch).
   3. Make your changes and commit them (git commit -m 'Add new feature').
   4. Push to the branch (git push origin feature-branch).
   5. Open a pull request.
