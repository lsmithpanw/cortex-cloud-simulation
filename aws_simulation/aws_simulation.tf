# ==========================================
# 1. POSTURE SIMULATION (CSPM)
# ==========================================
# RESOURCE: Unencrypted Private EBS Volume
# DESCRIPTION: This resource represents a "Compliance Failure" in cloud hygiene.
# WHY IT'S SAFE: It is a config-only violation. The volume is empty, not attached to any host, 
# and has no network path for data exfiltration or external access.
# CORTEX ALERT: "EBS Volume is not encrypted."
resource "aws_ebs_volume" "posture_sim" {
  count             = var.run_posture == "yes" ? 1 : 0
  availability_zone = "us-east-1a"
  size              = 1
  encrypted         = false 
  tags              = { Name = "Cortex-Posture-Simulation-Safe" }
}

# ==========================================
# 2. VULNERABILITY SIMULATION (CWP)
# ==========================================
# RESOURCE: Internal Legacy Host (Ubuntu 18.04)
# DESCRIPTION: Models "Technical Debt." This OS version is End-of-Life (EOL) and contains 
# 100+ known CVEs that the Cortex Agentless scanner will identify.
# WHY IT'S SAFE: 'associate_public_ip_address' is set to FALSE. This host has no public 
# footprint and cannot be reached or exploited from the internet.
# CORTEX ALERT: "Host OS version is EOL" and "Critical Vulnerabilities Detected."
resource "aws_instance" "vuln_sim" {
  count                       = var.run_vulnerability == "yes" ? 1 : 0
  ami                         = "ami-011899242ed902164" # Ubuntu 18.04 LTS
  instance_type               = "t3.micro"
  associate_public_ip_address = false 
  tags                        = { Name = "Cortex-Vulnerability-Simulation-Safe" }
}

# ==========================================
# 3. DATA & MALWARE SIMULATION (DDR)
# ==========================================
# RESOURCE: EICAR Test String in Private S3 Bucket
# DESCRIPTION: Demonstrates "Data Detection & Response." Cortex scans the storage layer 
# via API to identify malicious files within your data perimeter.
# WHY IT'S SAFE: The bucket is private. The file contains the harmless EICAR test string, 
# which is an industry-standard non-malicious file used to verify security logic.
# CORTEX ALERT: "Malicious file detected in S3 bucket."
resource "aws_s3_bucket" "malware_sim" {
  count         = var.run_malware == "yes" ? 1 : 0
  bucket        = "cortex-malware-sim-aws-${random_id.sim_id.hex}"
  force_destroy = true
}

resource "aws_s3_object" "eicar_file" {
  count   = var.run_malware == "yes" ? 1 : 0
  bucket  = aws_s3_bucket.malware_sim[0].id
  key     = "malware-test.txt"
  content = "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*"
}
