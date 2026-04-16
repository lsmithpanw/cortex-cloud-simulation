variable "gcp_project_id" {
  type        = string
  description = "Enter your GCP Project ID"
}

variable "run_posture" {
  type        = string
  description = "Do you want to run the GCP Posture simulation? (yes/no)"
}

variable "run_vulnerability" {
  type        = string
  description = "Do you want to run the GCP Vulnerability simulation? (yes/no)"
}

variable "run_malware" {
  type        = string
  description = "Do you want to run the GCP Malware simulation? (yes/no)"
}
