module "kuberhealthy" {
  source      = "../"
  cluster_env = terraform.workspace
}
