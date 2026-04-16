# ==========================================
# 1. POSTURE SIMULATION (Compliance)
# ==========================================
# RESOURCE: Insecure Storage Transfer
# DESCRIPTION: Violates "Best Practice Compliance" by allowing non-HTTPS (unencrypted) traffic.
# WHY IT'S SAFE: 'public_network_access_enabled' is FALSE. No one can reach this storage 
# from the public internet, making the unencrypted channel inaccessible to attackers.
# CORTEX ALERT: "Storage account should have 'Secure transfer required' enabled."
resource "azurerm_storage_account" "posture_sim" {
  count                     = var.run_posture == "yes" ? 1 : 0
  name                      = "ctxsimposture${random_id.sim_id.hex}"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = false 
  public_network_access_enabled = false 
}

# ==========================================
# 2. VULNERABILITY SIMULATION (Workload Security)
# ==========================================
# RESOURCE: Private VM with Legacy Image (Ubuntu 16.04)
# DESCRIPTION: Simulates "Stale Assets." Ubuntu 16.04 is long End-of-Life and is a 
# perfect target for showing vulnerability remediation workflows.
# WHY IT'S SAFE: The Network Interface has no Public IP. It is unreachable from the internet 
# and isolated within its virtual network.
# CORTEX ALERT: "Vulnerable OS Version Detected."
resource "azurerm_linux_virtual_machine" "vuln_sim" {
  count               = var.run_vulnerability == "yes" ? 1 : 0
  name                = "vuln-sim-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.nic[0].id]
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk { caching = "ReadWrite", storage_account_type = "Standard_LRS" }
}

# ==========================================
# 3. DATA & MALWARE SIMULATION (DDR/Blobs)
# ==========================================
# RESOURCE: Malware String in Private Blob Container
# DESCRIPTION: Demonstrates the Data Detection and Response (DDR) capabilities for Azure Blobs.
# WHY IT'S SAFE: The container access is private and the EICAR string is a non-exploitable 
# security test file.
# CORTEX ALERT: "Malicious blob detected."
resource "azurerm_storage_container" "malware_sim" {
  count                 = var.run_malware == "yes" ? 1 : 0
  name                  = "malware-sim-container"
  storage_account_name  = azurerm_storage_account.posture_sim[0].name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "eicar_blob" {
  count                  = var.run_malware == "yes" ? 1 : 0
  name                   = "eicar_test.txt"
  storage_account_name   = azurerm_storage_account.posture_sim[0].name
  storage_container_name = azurerm_storage_container.malware_sim[0].name
  type                   = "Block"
  source_content         = "X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*"
}
