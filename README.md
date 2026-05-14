# Cortex Cloud Security POV Simulation Toolkit

This toolkit demonstrates the detection and response capabilities of **Cortex Cloud** across AWS, GCP, and Azure. It provisions "Safe-by-Design" resources that simulate security risks without exposing your environment to actual threats.

---

## 🛡️ Safety & Privacy
* **Isolated Networking:** Every simulation creates a dedicated, air-gapped VPC/VNet with **no Internet Gateway**. 
* **No Public Exposure:** All VMs are provisioned in private subnets with **no Public IPs**.
* **Validated Test Malware:** Uses the official **Palo Alto Networks WildFire APK**—a non-executable Android package.
* **Zero Local Footprint:** The malware file is streamed directly from the official WildFire URL (from [this page](https://docs.paloaltonetworks.com/advanced-wildfire/administration/configure-advanced-wildfire-analysis/verify-wildfire-submissions/test-a-sample-malware-file)) to your cloud storage via the Cloud CLI.

---

## 📂 Project Structure
Organize your local directory as follows:

```
/cortex-cloud-simulation
  ├── aws_simulation/
  │   ├── aws_simulation.tf  # (Consolidated Simulation Logic)
  │   ├── provider.tf        # (Cloud Credentials/Region)
  │   └── variables.tf       # (Interactive Menu)
  ├── gcp_simulation/
  │   ├── gcp_simulation.tf
  │   ├── provider.tf
  │   └── variables.tf
  └── azure_simulation/
      ├── azure_simulation.tf
      ├── provider.tf
      └── variables.tf
```

## 🛠️ Prerequisites
Ensure you have the following installed and authenticated:

`Terraform CLI`

Authentication:

AWS: 
```
aws configure
```

GCP:
 ```
gcloud auth application-default login
```

Azure: 
```
az login
```

## 📖 Step-by-Step Instructions
### 1. Initialize
Navigate into the folder for the cloud provider you wish to test:

```
cd aws_simulation
terraform init
```

### 2. Interactive Apply
Run the apply command. Terraform will pause and ask you interactive questions:

```
terraform apply
```

The CLI will then ask:

```
[POSTURE] Enter 'yes' to CREATE/KEEP or 'no' to DESTROY/SKIP the Posture simulation:
[VULN] Enter 'yes' to CREATE/KEEP or 'no' to DESTROY/SKIP the Vulnerability simulation:
[MALWARE] Enter 'yes' to CREATE/KEEP or 'no' to DESTROY/SKIP the Malware simulation:
```

### 3. Verify in Cortex
Log in to your Cortex Cloud Console to see the alerts.

**Notes on Timing:**
* **Vulnerability Scanning:** Results typically appear after the next discovery cycle (**15–60 mins**).
* **Malware Detection:** Detected malware might take up to several days to appear in the console via standard automated cycles. In order to expedite the detection, perform an **on-demand scan**:
  * *(Inventory > All Assets > Data > Storage Buckets > Click on the bucket > Click on three dots on top right > Scan for Data)*

### 4. Cleanup
Always destroy resources after the POV to maintain environment hygiene:

```
terraform apply
```
When prompted, type `no` for all three interactive prompts. This will trigger Terraform to destroy the existing simulation assets.

## 📝 Important Notes
* **Cleanup Grace:** We have disabled "Object Lock" and "Legal Hold" in these scripts to ensure cleanup works instantly without manual CLI overrides.
* **Regions:** Defaults are `us-east-1` (AWS), `us-central1` (GCP), and your Resource Group location (Azure).
* **SSH Keys:** Azure scripts require a local public key at `~/.ssh/id_rsa.pub` for VM creation.
* **Sandbox:** Recommended for use in non-production accounts.
