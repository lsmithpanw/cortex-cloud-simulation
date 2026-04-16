variable "run_posture" {
  type        = string
  description = "Do you want to run the Azure Posture simulation? (yes/no)"
}

variable "run_vulnerability" {
  type        = string
  description = "Do you want to run the Azure Vulnerability simulation? (yes/no)"
}

variable "run_malware" {
  type        = string
  description = "Do you want to run the Azure Malware simulation? (yes/no)"
}
