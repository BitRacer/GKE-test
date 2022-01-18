resource "google_service_account" "anthos" {
  account_id   = "anthos-sa"
  display_name = "Anthos Hub Service Account"
  depends_on = [
    module.cyberquark_cluster
  ]
}

module "hub" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/hub"

  project_id       = data.google_client_config.current.project
  cluster_name     = module.cyberquark_cluster.name
  location         = module.cyberquark_cluster.location
  cluster_endpoint = module.cyberquark_cluster.endpoint
}
