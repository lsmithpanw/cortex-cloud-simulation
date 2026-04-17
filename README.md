# Cortex Cloud Security POV Simulation Toolkit

This toolkit demonstrates the detection and response capabilities of **Cortex Cloud** across AWS, GCP, and Azure. It provisions "Safe-by-Design" resources that simulate security risks without exposing your environment to actual threats.

---

## 🛡️ Safety & Privacy
* **No Public Exposure:** All VMs are provisioned without Public IPs.
* **Private Storage:** All storage buckets are private and hardened.
* **Inert Malware:** Uses the industry-standard **EICAR** test string (harmless text).
* **Isolated Assets:** Scripts create *new* resources and do not modify existing data.

---

## 📂 Project Structure
Organize your local directory as follows for the scripts to function correctly:

```
/cortex-cloud-simulation
  ├── aws_simulation/
  │   ├── providers.tf
  │   ├── variables.tf
  │   └── aws_simulation.tf
  ├── gcp_simulation/
  │   ├── providers.tf
  │   ├── variables.tf
  │   └── gcp_simulation.tf
  └── azure_simulation/
      ├── providers.tf
      ├── variables.tf
      └── azure_simulation.tf
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
Do you want to run Posture simulation? (yes/no)
Do you want to run Vulnerability simulation? (yes/no)
Do you want to run Malware simulation? (yes/no)
```

Type `yes` to deploy or `no` to skip.

### 3. Verify in Cortex
Log in to your Cortex Cloud Console to see the alerts.

Note: Vulnerability scanning results appear after the next discovery cycle (15–60 mins).

### 4. Cleanup
Always destroy resources after the POV to maintain environment hygiene:

```
terraform destroy
```

## 📝 Important Notes
Regions: Default is `us-east-1` (AWS) or `us-central1` (GCP). Update `providers.tf` if needed.

Sandbox: Recommended for use in non-production accounts.
