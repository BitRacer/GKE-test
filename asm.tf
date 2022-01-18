module "asm-cyberquark" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  version          = "13.0.0"
  project_id            = data.google_client_config.current.project
  cluster_name          = module.cyberquark_cluster.name
  location              = module.cyberquark_cluster.location
  cluster_endpoint      = module.cyberquark_cluster.endpoint
  asm_dir               = "asm-dir-${module.cyberquark_cluster.name}"
  /*depends_on = [
    module.hub-cyberquark.wait
  ]*/
}


/*
module "asm-cyberquark" {
  source                = "terraform-google-modules/kubernetes-engine/google//modules/asm"

  project_id            = data.google_client_config.current.project
  cluster_name          = module.cyberquark_cluster.name
  location              = module.cyberquark_cluster.location
  cluster_endpoint      = module.cyberquark_cluster.endpoint
  enable_all            = false
  enable_cluster_roles  = true
  enable_cluster_labels = false
  enable_gcp_apis       = false
  enable_gcp_iam_roles  = true
  enable_gcp_components = true
  enable_registration   = false
  managed_control_plane = false
  options               = ["envoy-access-log,egressgateways"]
  custom_overlays       = ["./custom_ingress_gateway.yaml"]
  skip_validation       = true
  outdir                = "./${module.gke.name}-outdir-${var.asm_version}"
}

*/