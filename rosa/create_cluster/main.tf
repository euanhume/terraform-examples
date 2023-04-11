terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.0"
    }
    ocm = {
      version = " 1.0.1"
      source  = "terraform-redhat/ocm"
    }
  }
}

provider "ocm" {
  token = var.token
  url   = var.url
}

locals {
  sts_roles = {
    role_arn         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_prefix}-Installer-Role",
    support_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_prefix}-Support-Role",
    instance_iam_roles = {
      master_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_prefix}-ControlPlane-Role",
      worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_prefix}-Worker-Role"
    },
    operator_role_prefix = var.operator_role_prefix,
  }
}

data "aws_caller_identity" "current" {
}

resource "ocm_cluster_rosa_classic" "rosa_sts_cluster" {
  name               = "tf-cluster"
  cloud_region       = "eu-west-2"
  aws_account_id     = data.aws_caller_identity.current.account_id
  availability_zones = ["eu-west-2a"]
  properties = {
    rosa_creator_arn = data.aws_caller_identity.current.arn
  }
  sts = local.sts_roles
  tags = {
    "product" = "openshift",
    "foo"     = "bar"
  }
  version = "openshift-v4.12.0"
  lifecycle {
    ignore_changes = [
      version,
    ]
  }
}

resource "ocm_cluster_wait" "rosa_cluster" {
  cluster = ocm_cluster_rosa_classic.rosa_sts_cluster.id
  # timeout in minutes
  timeout = 60
}

data "ocm_rosa_operator_roles" "operator_roles" {
  operator_role_prefix = var.operator_role_prefix
  account_role_prefix  = var.account_role_prefix
}

module "operator_roles" {
  source  = "terraform-redhat/rosa-sts/aws"
  version = "0.0.4"

  create_operator_roles = true
  create_oidc_provider  = true
  create_account_roles  = false

  cluster_id                  = ocm_cluster_rosa_classic.rosa_sts_cluster.id
  rh_oidc_provider_thumbprint = ocm_cluster_rosa_classic.rosa_sts_cluster.sts.thumbprint
  rh_oidc_provider_url        = ocm_cluster_rosa_classic.rosa_sts_cluster.sts.oidc_endpoint_url
  operator_roles_properties   = data.ocm_rosa_operator_roles.operator_roles.operator_iam_roles
}