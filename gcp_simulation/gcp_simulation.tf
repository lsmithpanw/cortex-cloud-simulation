# ==========================================
# 1. POSTURE SIMULATION (CIEM/Identity)
# ==========================================
# RESOURCE: Over-privileged Service Account
# DESCRIPTION: Simulates "Identity Over-Privilege." Assigning the 'Owner' role to a 
# service account violates the principle of least privilege.
# WHY IT'S SAFE: The service account is a dummy identity. No JSON keys are generated, 
# and it is not attached to any VM, so it cannot be used by an external actor.
# CORTEX ALERT: "Service Account with excessive permissions (Owner)."
resource "google_project_iam_binding" "posture_sim" {
  count   = var.run_posture == "yes" ? 1 : 0
  project = var.gcp_project_id
  role    = "roles/owner"
  members = ["serviceAccount:sim-identity@${var.gcp_project_id}.iam.gserviceaccount.com"]
}

# ==========================================
# 2. VULNERABILITY SIMULATION (CWP/Containers)
# ==========================================
# RESOURCE: Internal Vulnerable Container (Nginx 1.14)
# DESCRIPTION: Simulates "Software Supply Chain Risk." Older Nginx images contain 
# several High and Critical vulnerabilities that Cortex will flag.
# WHY IT'S SAFE: The instance has NO public IP and is isolated on the internal network. 
# It is a "living lab" for the vulnerability scanner without external risk.
# CORTEX ALERT: "Vulnerable Container Image Detected."
resource "google_compute_instance" "vuln_sim" {
  count        = var.run_vulnerability == "yes" ? 1 : 0
  name         = "vulnerability-sim-cve"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  boot_disk { initialize_params { image = "cos-cloud/cos-stable" } }
  network_interface { network = "default" }
  metadata = {
    gce-container-declaration = "spec:\n  containers:\n    - name: nginx\n      image: nginx:1.14.0"
  }
}

# ==========================================
# 3. DATA & MALWARE SIMULATION (DDR/GCS)
# ==========================================
# RESOURCE: Malware String in Private GCS Bucket
# DESCRIPTION: Tests Cortex's ability to scan cloud storage for active threats via API.
# WHY IT'S SAFE: Public access prevention is enforced. The EICAR string is harmless 
# and triggers a detection event without introducing real malicious code.
# CORTEX ALERT: "GCS Bucket Malware Finding."
resource "google_storage_bucket" "malware_sim" {
  count                    = var.run_malware == "yes" ? 1 : 0
  name                     = "cortex-malware-sim-gcp-${random_id.sim_id.hex}"
  location                 = "US"
  public_access_prevention = "enforced"
}

resource "google_storage_bucket_object" "eicar_file" {
  count   = var.run_malware == "yes" ? 1 : 0
  name    = "eicar_test.txt"
  bucket  = google_storage_bucket.malware_sim[0].name
  content = "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*"
}
