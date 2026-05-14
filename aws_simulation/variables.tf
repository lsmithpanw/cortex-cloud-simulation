# ==========================================
# SIMULATION CONTROL CENTER (INTERACTIVE)
# ==========================================
# Instructions: 
# Run 'terraform apply' to manage simulations.
#
# [yes] -> CREATE a new simulation or KEEP an existing one running.
# [no/ENTER]  -> DESTROY an existing simulation or SKIP the deployment.
# ==========================================

variable "run_posture" {
  type        = string
  description = "\n[POSTURE] Enter 'yes' to CREATE/KEEP or 'no' to DESTROY/SKIP the Posture simulation:"
}

variable "run_vulnerability" {
  type        = string
  description = "\n[VULN] Enter 'yes' to CREATE/KEEP or 'no' to DESTROY/SKIP the Vulnerability simulation:"
}

variable "run_malware" {
  type        = string
  description = "\n[MALWARE] Enter 'yes' to CREATE/KEEP or 'no' to DESTROY/SKIP the Malware simulation:"
}