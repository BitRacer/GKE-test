data "google_client_config" "current" {}

data "google_project" "project" {
  project_id = var.project_id
}

output "project" {
  value = data.google_client_config.current.project
}

resource "google_service_account" "nodes" {
  account_id   = "node-sa"
  display_name = "GKE Nodes Service Account"
}

module "project-services" {
  source = "terraform-google-modules/project-factory/google//modules/project_services"

  project_id                  = data.google_client_config.current.project
  disable_services_on_destroy = false
  activate_apis = [
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "anthos.googleapis.com",
    "cloudtrace.googleapis.com",
    "meshca.googleapis.com",
    "meshtelemetry.googleapis.com",
    "meshconfig.googleapis.com",
    "iamcredentials.googleapis.com",
    "gkeconnect.googleapis.com",
    "gkehub.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ]
}

module "cyberquark_cluster" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = data.google_project.project.project_id
  name                       = "cyberquark-cluster"
  region                     = "us-central1"
  zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
  network                    = "vpc-01"
  subnetwork                 = "us-central1-01"
  ip_range_pods              = "us-central1-01-gke-01-pods"
  ip_range_services          = "us-central1-01-gke-01-services"
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = false

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-standard-4"
      node_locations     = "us-central1-b,us-central1-c"
      min_count          = 1
      max_count          = 100
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "google_service_account.nodes.email"
      preemptible        = false
      initial_node_count = 80
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}

