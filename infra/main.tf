module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
  eks_cluster_default_sg = module.eks.eks_cluster_default_sg
}

module "ecr" {
  source = "./modules/ecr"
}

module "eks" {
  source = "./modules/eks"
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  # my_ip = var.my_ip
  vpc_id = module.vpc.vpc_id
  ami = var.ami
  instance_type = var.instance_type
}

module "pod_identity" {
  source = "./modules/pod-identity"
  eks_cluster_name = module.eks.cluster_name
}