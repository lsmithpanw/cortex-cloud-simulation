terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
    random = { source = "hashicorp/random", version = "~> 3.0" }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
}

resource "random_id" "sim_id" {
  byte_length = 4
}
