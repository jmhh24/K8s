terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region  = "us-east-1"
  profile = "jmh"
}

# Create VPC

module "vpc" {
  source        = "./modules/net-staff"
  stage         = var.stage
  vpc_cidr      = var.vpc_cidr
  private1_cidr = var.private1_cidr
  private2_cidr = var.private2_cidr
  public1_cidr  = var.public1_cidr
  public2_cidr  = var.public2_cidr

}

#Create EKS

module "eks" {
  source           = "./modules/EKS"
  sub_private_1_id = module.vpc.sub_private_1_id
  sub_private_2_id = module.vpc.sub_private_2_id
  sub_public_1_id  = module.vpc.sub_public_1_id
  sub_public_2_id  = module.vpc.sub_public_2_id


}