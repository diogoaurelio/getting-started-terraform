# Getting started to terraform

# Before you jump the guns ...

 Before getting started
- When developing for Cloud Providers, do browse the GUI; 
- Hackathon/manual-testing: append distintive prefix on manual resources, example: "delete-me-"; 
- even better: have/use dedicated test account, use [AWS Nuke](https://github.com/rebuy-de/aws-nuke) to clean-up resources;

# Intro 

What is terraform?
- Open-source written in Go;
- DSL for resource instantiation in a declarative manner;
- multi-provider in one place: Cloud Providers (AWS, GCP, Azure, DigitalOcean, Packet, BaiduCloud, Oracle Cloud, CloudFlare, TencentCloud, MongoDB Atlas), infrastructure (K8s, Helm, Rancher, CheckPoint, Cisco ASA/ACI, VMware, F5), DBs (PostGres, MySQL), Git (Github, GitLab, BitBucket), etc.
- multi-cloud; however: did not fall into the mistake of creating abstractions over cloud - providers; this means in practice they can still stay feature rich;
- masterless - shared backend to store state-file for synchronization
- agentless;
- tries immutability principle (whenever possible), as opposed to other tools such as Chef/Puppet, Ansible;
- great for provisioning, not necessarily for config; a lot of people combine with Tools for configuration, such as Ansible/Puppet/Chef;


# Local setup

1) [Download terraform](https://www.terraform.io/downloads.html)

Example for version 0.12.21:
```bash
export TF_VERSION=0.12.21
# Linux
curl https://releases.hashicorp.com/terraform/$TF_VERSION/terraform_${TF_VERSION}_linux_amd64.zip --output /tmp/terraform.zip
# Mac
curl https://releases.hashicorp.com/terraform/$TF_VERSION/terraform_${TF_VERSION}_darwin_amd64.zip --output /tmp/terraform.zip

# Setup locally
unzip /tmp/terraform.zip -d /tmp && chmod +x /tmp/terraform && mv /tmp/terraform /usr/local/bin/

# confirm it is correctly setup in your system:
terraform version
```

2) [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
 
```bash
# on Linux: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# on Mac: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
``` 

3) Setup AWS profile

```bash
aws configure --profile test
export AWS_PROFILE=test
```


# Terraform VS cloudformation

Tf - terraform;
Cf - CloudFormation

pro cf:

- Tf: conditional deployments quite clunky (with [count parameter](https://www.terraform.io/intro/examples/count.html)); Cf: conditionals more explicit syntax; see example [here](https://hackernoon.com/your-infrastructure-as-code-cloudformation-vs-terraform-34ec5fb5f044)
- Tf: error handling sometimes hard; Cf: UI provides extensive detail on failed resources with reasons;
- Tf: drift detection possible with refresh (on manual resource delete for example); Cf provides drift detection functionality;

pro tf:
- Tf: multi-provider; Cf: aws specific; 
- Tf: clean syntax; Cf: verbose yaml/json syntax;
- Tf: separates plan from execution phase; Cf immediate execution;
- Tf: handles failure by tainting resources, and attempting to re-create failed resources on next phase; Cf: entire stack rollback;
- Tf: feature support quite fast; surprisingly, Cf has a history of lagging behind ...
- Tf: rich set of [built-in functions (such as loops)](https://www.terraform.io/docs/configuration/functions.html), [type constraints](https://www.terraform.io/docs/configuration/types.html); Cf: more limited functions [intrinsic Functions](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html)
```hcl
# in the terminal run `terraform console`:

# from string to json:
jsondecode("{\"hello\": \"world\"}")
# note that it will correctly map object to its type
jsondecode("{\"hello\": true}")

# ... and encoding as well
jsonencode({"hello"="world"})


# subnet calculation
cidrsubnet("172.16.0.0/12", 4, 2) 

# datetime
formatdate("DD MMM YYYY hh:mm ZZZ", "2018-01-02T23:12:01Z")
timestamp()
timeadd("2017-11-22T00:00:00Z", "10m")

# filesystem
fileexists("${path.module}/.gitignore")
file("${path.module}/README.md")

jsondecode(file("${path.module}/templates/example_step_function.json"))

```


Make up your own mind, plenty of reading material out there on this topic:
- https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c
- https://medium.com/@endofcake/terraform-vs-cloudformation-1d9716122623



# State-file

- [state-file](https://www.terraform.io/docs/state/index.html) used for resource [metadata](https://www.terraform.io/docs/state/purpose.html#metadata) such as dependency & order mapping: https://www.terraform.io/docs/state/purpose.html#metadata
- state-file also helps with performance on very large infrastructures - state is treated as the source of truth;
- backend - remote state is the recommended way for collaboration in teams;
- concurrency can be dealt by using state locks;



# Basics

## resources

Instantiate infrastructure objects:
```hcl
resource "aws_instance" "web" {
  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
}

```
 
## data 
Allows to fetch information from already existing resources;

```hcl
data "aws_ami" "example" {
  most_recent = true

  owners = ["self"]
  tags = {
    Name   = "app-server"
    Tested = "true"
  }
}
```

## locals
A local value assigns a name to an expression, allowing it to be used multiple times within a module without repeating it.

```hcl
locals {
  service_name = "forum"
  owner        = "Community Team"
}
``` 

## terraform settings

Configuring terraform settings, such as minimum required version, and backend:

```hcl
terraform {
  backend "s3" {
    # (backend-specific settings...)
  }
}
```

More details on [constraining the required version here](https://www.terraform.io/docs/configuration/terraform.html#specifying-a-required-terraform-version)


# New terraform version 0.12

## types

Also supports [dynamic types](https://www.terraform.io/docs/configuration/types.html#dynamic-types-the-quot-any-quot-constraint)


## loops
Advance (awesome) features, dynamic blocks:
```hcl
variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type        = map(string)
  default     = { key = "Name", value = "test"}
}

resource "aws_autoscaling_group" "example" {
  # (...)
  
  dynamic "tag" {
    # Use for_each to loop over var.custom_tags
    for_each = var.custom_tags
    # In each iteration, set the following arguments in the 
    # tag block
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

```

More details on loops [by terragrunt](https://blog.gruntwork.io/terraform-tips-tricks-loops-if-statements-and-gotchas-f739bbae55f9)


# Tf commands

```bash
# format code
terraform fmt 
# initialize
terraform init 

# view detailed execution plan 
terraform plan

# deploy resources
terraform apply

```

Other sometimes nice-to-have:
- refresh: kind of drift detection, compares actual deployed resources with state-file, and updates it; does not actually apply any changes;
- taint: mark a resource for removal in state file; will be removed in next execution;
- graph: build visual graph;
- 0.12upgrade: upgrade a 0.11.X "old" module into new syntax;


# Modules

[Modules](https://www.terraform.io/docs/configuration/modules.html)

Way of DRYing code & encapsulating abstractions

There can be different [module sources](https://medium.com/@endofcake/terraform-vs-cloudformation-1d9716122623), from local, to git, S3, etc. 

# Best Practices summary


## general

- coding terraform - follow incremental evolution; baby step commits are better!
- start with main.tf, variables.tf, outputs.tf : These are the recommended filenames for a minimal module, even if they're empty. main.tf should be the primary entrypoint. source:  https://www.terraform.io/docs/modules/index.html#standard-module-structure 
- avoid hard-coding things - use variables; Variables should have descriptions, and should leverage type safety. 


## terraform config
- specify minimum required tf version - https://www.terraform.io/docs/configuration-0-11/terraform.html#example ; you might also want to specify the providers minimum version as well;
- [backends](https://www.terraform.io/docs/backends/index.html) use remote state (managing a tfstate file in git is a nightmare) and if using S3, make it a versioned bucket; note: s3 backend only persists data in S3, otherwise in memory of local execution;
- Limit Blast radius is smaller with fewer resources: Insulating unrelated resources from each other by placing them in separate compositions reduces the risk if something goes wrong; 


## modules

- use modules: DRY code, keep them composable & reusable;
- building modules: keep them small, use IoC pattern; IoC also helps avoid building expensive conditional logic that makes modules big & hard to read; more on module composition : https://www.terraform.io/docs/modules/composition.html  
- data only modules: can be very useful when multiple teams instantiate on shared resources (classic example is a VPC), as modules can evolve independently reference: https://www.terraform.io/docs/modules/composition.html#data-only-modules  
- consistent naming conventions - see cloudposse label module: https://github.com/cloudposse/terraform-terraform-label;

## others

- use CI/CD tools for deployment: recommended  workflow will run terraform fmt, terraform init, terraform validate, and terraform plan on all *.tf; example with github actions: https://www.terraform.io/docs/github-actions/getting-started.html
- debugging: TF_LOG to one of the log levels TRACE, DEBUG, INFO, WARN or ERROR to change the verbosity of the logs.
