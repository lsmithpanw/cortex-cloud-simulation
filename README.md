# Cortex Cloud Security POV Simulation Toolkit

This toolkit demonstrates the detection and response capabilities of **Cortex Cloud** across AWS, GCP, and Azure. It provisions "Safe-by-Design" resources that simulate security risks without exposing your environment to actual threats.

---

## 🛡️ Safety & Privacy
* **Isolated Networking:** Every simulation creates a dedicated, air-gapped VPC/VNet with **no Internet Gateway**. 
* **No Public Exposure:** All VMs are provisioned in private subnets with **no Public IPs**.
* **Validated Test Malware:** Uses the official **Palo Alto Networks WildFire APK**—a non-executable Android package designed for safe security testing

---

## 📂 Project Structure
Organize your local directory as follows. **Ensure the `malware.apk` file is present in every cloud folder** for the DSPM simulations to work:

```
/cortex-cloud-simulation
  ├── aws_simulation/
  │   ├── aws_simulation.tf  # (Consolidated Simulation Logic)
  │   ├── provider.tf        # (Cloud Credentials/Region)
  │   ├── variables.tf       # (Interactive Menu)
  │   └── malware.apk        # <--- MUST BE PRESENT
  ├── gcp_simulation/
  │   ├── gcp_simulation.tf
  │   ├── provider.tf
  │   ├── variables.tf
  │   └── malware.apk        # <--- MUST BE PRESENT
  └── azure_simulation/
      ├── azure_simulation.tf
      ├── provider.tf
      ├── variables.tf
      └── malware.apk        # <--- MUST BE PRESENT
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

Note: Vulnerability scanning results appear after the next discovery cycle (15–60 mins).

### 4. Cleanup
Always destroy resources after the POV to maintain environment hygiene:

```
terraform apply
```
Then provide a `no` to all the interactive prompts to destroy all.

## 📝 Important Notes
* **Cleanup Grace:** We have disabled "Object Lock" and "Legal Hold" in these scripts to ensure cleanup works instantly without manual CLI overrides.
* **Regions:** Defaults are `us-east-1` (AWS), `us-central1` (GCP), and your Resource Group location (Azure).
* **SSH Keys:** Azure scripts require a local public key at `~/.ssh/id_rsa.pub` for VM creation.
* **Sandbox:** Recommended for use in non-production accounts.
