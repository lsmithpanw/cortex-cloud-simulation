# ==========================================
# 0. NETWORK INFRASTRUCTURE (Isolated VPC)
# ==========================================
# Creates a dedicated, air-gapped network for simulations. 
# No Internet Gateway is attached to ensure absolute safety.

resource "aws_vpc" "simulation_vpc" {
  count      = var.run_vulnerability == "yes" ? 1 : 0
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Cortex-Simulation-VPC"
  }
}

resource "aws_subnet" "simulation_subnet" {
  count      = var.run_vulnerability == "yes" ? 1 : 0
  vpc_id     = aws_vpc.simulation_vpc[0].id
  cidr_block = "10.0.1.0/24"
  
  tags = {
    Name = "Cortex-Simulation-Subnet"
  }
}

# ==========================================
# 1. POSTURE SIMULATION (CSPM)
# ==========================================
# RESOURCE: Private S3 Bucket with Security Gaps
# DESCRIPTION: Models "Configuration Drift." This asset is intentionally 
# deployed without standard security controls.
#
# CORTEX ALERTS: 
# 1. AWS S3 Object Versioning is disabled. 
# 2. AWS S3 bucket policy does not enforce HTTPS request only.

resource "aws_s3_bucket" "posture_sim_gap" {
  count         = var.run_posture == "yes" ? 1 : 0
  bucket_prefix = "cortex-posture-gap-"
  force_destroy = true

  tags = {
    Simulation-Type = "Cortex-Posture-Simulation-Safe"
  }
}

# ==========================================
# 2. VULNERABILITY SIMULATION (CWP)
# ==========================================
# RESOURCE: Internal Legacy Host (Ubuntu 18.04)
# DESCRIPTION: Models "Technical Debt." Uses an EOL OS version with 
# known CVEs for Agentless scanner detection.

data "aws_ami" "ubuntu_18_04" {
  most_recent        = true
  owners             = ["099720109477"] # Canonical
  include_deprecated = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "vuln_sim" {
  count                       = var.run_vulnerability == "yes" ? 1 : 0
  ami                         = data.aws_ami.ubuntu_18_04.id
  instance_type               = "t2.micro" 
  subnet_id                   = aws_subnet.simulation_subnet[0].id
  associate_public_ip_address = false 

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }

  tags = { 
    Name            = "Cortex-Vuln-Simulation"
    Simulation-Type = "Cortex-Vulnerability-Simulation-Safe"
  }
}

# ==========================================
# 3. DATA MALWARE SIMULATION (DSPM)
# ==========================================
# RESOURCE: Official Palo Alto Networks WildFire Test APK
# DESCRIPTION: Uploads a verified malware sample to S3 for detection.

locals {
  malware_enabled = var.run_malware == "yes" ? 1 : 0
  local_file_path = "${path.module}/malware.apk"
}

resource "aws_s3_bucket" "malware_sim_bucket" {
  count         = local.malware_enabled
  bucket_prefix = "cortex-malware-sim-scan-"
  force_destroy = true 
}

resource "aws_s3_object" "apk_malware_file" {
  count  = local.malware_enabled
  bucket = aws_s3_bucket.malware_sim_bucket[0].id
  
  # The name as it will appear in the Cortex console/Alerts
  key    = "malaware-sim-file.apk"
  
  # Pointing to your local file
  source = local.local_file_path

  # Ensures Terraform detects if you swap the file for a different sample
  etag   = filemd5(local.local_file_path)

  content_type           = "application/vnd.android.package-archive"
  server_side_encryption = "AES256"

  tags = {
    Simulation-Type = "Cortex-Official-WildFire-Malware-Simulation-Safe"
  }
}