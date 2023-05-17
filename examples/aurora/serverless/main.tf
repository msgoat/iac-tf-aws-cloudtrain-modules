terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      version = "~> 3.0"
    }
  }
}

provider aws {
  region = var.region_name
}

module network {
  source = "../../../modules/network/vpc"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = var.common_tags
  network_name = "iactst23"
  network_cidr = "10.0.0.0/16"
  inbound_traffic_cidrs = [ "0.0.0.0/0" ]
  nat_strategy = "NAT_GATEWAY_SINGLE"
  subnet_templates = [
    {
      subnet_name   = "web"
      accessibility = "public"
      newbits       = 8
      tags          = {}
    },
    {
      subnet_name   = "db"
      accessibility = "private"
      newbits       = 4
      tags          = {}
    }
  ]
}

module aurora {
  source = "../../../modules/database/aurora/serverless"
  region_name = var.region_name
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  solution_fqn = var.solution_fqn
  common_tags = var.common_tags
  db_instance_name = "iactst23"
  db_database_name = "iactst23"
  vpc_id = module.network.vpc_id
  db_subnet_ids = [ for sn in module.network.subnets : sn.subnet_id if sn.subnet_template_name == "db" ]
}