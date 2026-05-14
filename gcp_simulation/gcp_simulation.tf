# ==========================================
# 0. NETWORK INFRASTRUCTURE (Isolated VPC)
# ==========================================
# Creates a dedicated, air-gapped network for simulations. 
# No Cloud NAT or External IPs are attached to ensure absolute safety.

resource "google_compute_network" "simulation_vpc" {
  count                   = var.run_vulnerability == "yes" ? 1 : 0
  name                    = "cortex-simulation-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "simulation_subnet" {
  count         = var.run_vulnerability == "yes" ? 1 : 0
  name          = "cortex-simulation-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.simulation_vpc[0].id
}

# ==========================================
# 1. POSTURE SIMULATION (CSPM)
# ==========================================
# RESOURCE: Private GCS Bucket with Security Gaps
# DESCRIPTION: Models "Configuration Drift." This asset is intentionally 
# deployed without standard security controls.
#
# CORTEX ALERTS: 
# 1. GCS Bucket should have 'Uniform bucket-level access' enabled.
# 2. GCS Bucket should have versioning enabled.

resource "google_storage_bucket" "posture_sim_gap" {
  count         = var.run_posture == "yes" ? 1 : 0
  name          = "ctx-posture-gap-${random_id.sim_id.hex}"
  location      = "US"
  force_destroy = true

  # Set to enforced to ensure the asset is NOT public
  public_access_prevention = "enforced"

  # Intentionally disabled to trigger CSPM alerts
  uniform_bucket_level_access = false 
  
  versioning {
    enabled = false
  }

  labels = {
    simulation-type = "cortex-posture-simulation-safe"
  }
}

# ==========================================
# 2. VULNERABILITY SIMULATION (CWP)
# ==========================================
# RESOURCE: Internal Legacy Host (Ubuntu 16.04)
# DESCRIPTION: Models "Technical Debt." Uses an EOL OS version with 
# known CVEs for Agentless scanner detection.

resource "google_compute_instance" "vuln_sim" {
  count        = var.run_vulnerability == "yes" ? 1 : 0
  name         = "cortex-vuln-sim"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.simulation_subnet[0].id
    # No access_config block ensures NO Public IP is assigned
  }

  labels = {
    name            = "cortex-vuln-simulation"
    simulation-type = "cortex-vulnerability-simulation-safe"
  }
}

# ==========================================
# 3. DATA MALWARE SIMULATION (DSPM)
# ==========================================
# RESOURCE: Official Palo Alto Networks WildFire Test APK
# DESCRIPTION: Streams a verified malware sample directly into a GCS Bucket.
# WHY IT'S SAFE: Uses Public Access Prevention (Enforced) and identity-based 
# streaming to ensure the file is never accessible or locally stored.

resource "google_storage_bucket" "malware_sim_bucket" {
  count                    = var.run_malware == "yes" ? 1 : 0
  name                     = "ctx-malware-sim-scan-${random_id.sim_id.hex}"
  location                 = "US"
  force_destroy            = true
  public_access_prevention = "enforced"
}

resource "terraform_data" "download_malware_gcp" {
  count = var.run_malware == "yes" ? 1 : 0

  triggers_replace = [
    google_storage_bucket.malware_sim_bucket[0].name
  ]

  provisioner "local-exec" {
    # File name: malaware-sim-file.apk
    # Metadata used for Cortex classification: cortex-official-wildfire-malware-simulation-safe
    command = "curl -sL https://wildfire.paloaltonetworks.com/publicapi/test/apk | gcloud storage cp - gs://${google_storage_bucket.malware_sim_bucket[0].name}/malaware-sim-file.apk --custom-metadata=simulation-type=cortex-official-wildfire-malware-simulation-safe"
  }
}