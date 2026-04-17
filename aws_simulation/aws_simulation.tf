# ==========================================
# 0. DEDICATED SIMULATION NETWORK (VPC)
# ==========================================
resource "aws_vpc" "sim_vpc" {
  # Create the VPC if EITHER Posture or Vulnerability is 'yes'
  count      = (var.run_posture == "yes" || var.run_vulnerability == "yes") ? 1 : 0
  cidr_block = "10.99.0.0/16"
  tags       = { Name = "Cortex-Simulation-VPC" }
}

resource "aws_subnet" "sim_subnet" {
  count             = (var.run_posture == "yes" || var.run_vulnerability == "yes") ? 1 : 0
  vpc_id            = aws_vpc.sim_vpc[0].id
  cidr_block        = "10.99.1.0/24"
  availability_zone = "us-east-1a" # Hardcoded to match EBS for simplicity
  tags              = { Name = "Cortex-Simulation-Subnet" }
}

# ==========================================
# 1. POSTURE SIMULATION (CSPM)
# ==========================================
# RESOURCE: Unencrypted Private EBS Volume
# DESCRIPTION: Models a "Compliance Failure" in cloud hygiene. We provision this 
# volume into our dedicated simulation AZ (us-east-1a) to demonstrate how Cortex 
# identifies unencrypted storage.
# WHY IT'S SAFE: It is a config-only violation. The volume is empty, not attached 
# to any host, and is isolated within a private simulation-only VPC. It has no network
# path for data exfiltration or external access.
# CORTEX ALERT: "EBS Volume is not encrypted."
resource "aws_ebs_volume" "posture_sim" {
  count             = var.run_posture == "yes" ? 1 : 0
  availability_zone = "us-east-1a" # Matches the Subnet AZ
  size              = 1
  encrypted         = false  # CSPM triggers on unencrypted
  tags              = { Name = "Cortex-Posture-Simulation-Safe" }
}

# ==========================================
# 2. VULNERABILITY SIMULATION (CWP)
# ==========================================
# RESOURCE: Internal Legacy Host (Ubuntu 18.04)
# DESCRIPTION: Models "Technical Debt." We use the Data Source below to dynamically 
# find an official Ubuntu 18.04 image. This OS version is End-of-Life (EOL) and 
# contains 100+ known CVEs that the Cortex Agentless scanner will identify.
# WHY IT'S SAFE: This host is placed in a dedicated private subnet with 
# 'associate_public_ip_address' set to FALSE. It has no public footprint and 
# cannot be reached or exploited from the internet.
# CORTEX ALERT: "Host OS version is EOL" and "Critical Vulnerabilities Detected."
data "aws_ami" "ubuntu_18_04" {
  most_recent        = true
  owners             = ["099720109477"] 
  include_deprecated = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "vuln_sim" {
  count                       = var.run_vulnerability == "yes" ? 1 : 0
  ami                         = data.aws_ami.ubuntu_18_04.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.sim_subnet[0].id
  associate_public_ip_address = false 
  tags                        = { Name = "Cortex-Vulnerability-Simulation-Safe" }
}

# ==========================================
# 3. DATA & MALWARE SIMULATION (DDR)
# ==========================================
# RESOURCE: EICAR Test String in Private S3 Bucket
# DESCRIPTION: Demonstrates "Data Detection & Response." Cortex scans the storage layer 
# via API to identify malicious files within your data perimeter.
# WHY IT'S SAFE: The bucket is private (all new S3 buckets have "Block Public Access" 
# enabled by default). The file contains the harmless EICAR test string, 
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
