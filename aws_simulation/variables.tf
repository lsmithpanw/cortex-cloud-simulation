variable "run_posture" {
  type        = string
  description = "Do you want to run the AWS Posture simulation? (yes/no)"
}

variable "run_vulnerability" {
  type        = string
  description = "Do you want to run the AWS Vulnerability simulation? (yes/no)"
}

variable "run_malware" {
  type        = string
  description = "Do you want to run the AWS Malware simulation? (yes/no)"
}
