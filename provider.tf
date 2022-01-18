provider "google" {
  credentials = file("CREDENTIALS_FILE.json")
  project     = var.project_id
  region      = var.primary_region
}


