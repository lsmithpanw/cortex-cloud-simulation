# ==========================================
# 0. NETWORK INFRASTRUCTURE (Isolated VNet)
# ==========================================
# Creates a dedicated, air-gapped network for simulations. 
# No Public IP or Gateway is attached to ensure absolute safety.

resource "azurerm_virtual_network" "simulation_vnet" {
  count               = var.run_vulnerability == "yes" ? 1 : 0
  name                = "cortex-simulation-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "simulation_subnet" {
  count                = var.run_vulnerability == "yes" ? 1 : 0
  name                 = "cortex-simulation-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.simulation_vnet[0].name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "simulation_nic" {
  count               = var.run_vulnerability == "yes" ? 1 : 0
  name                = "cortex-sim-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.simulation_subnet[0].id
    private_ip_address_allocation = "Dynamic"
  }
}

# ==========================================
# 1. POSTURE SIMULATION (CSPM)
# ==========================================
# RESOURCE: Private Storage Account with Security Gaps
# DESCRIPTION: Models "Configuration Drift." This asset is intentionally 
# deployed without standard security controls.
#
# CORTEX ALERTS: 
# 1. Storage account should have 'Secure transfer required' enabled.
# 2. Storage account blob service should have versioning enabled.

resource "azurerm_storage_account" "posture_sim_gap" {
  count                     = var.run_posture == "yes" ? 1 : 0
  name                      = "ctxposturegap${random_id.sim_id.hex}"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  
  # Intentionally disabled to trigger CSPM alerts
  enable_https_traffic_only      = false 
  
  # Set to false to ensure the asset is NOT public
  public_network_access_enabled  = false 

  blob_properties {
    versioning_enabled = false
  }

  tags = {
    Simulation-Type = "Cortex-Posture-Simulation-Safe"
  }
}

# ==========================================
# 2. VULNERABILITY SIMULATION (CWP)
# ==========================================
# RESOURCE: Internal Legacy Host (Ubuntu 16.04)
# DESCRIPTION: Models "Technical Debt." Uses an EOL OS version with 
# known CVEs for Agentless scanner detection.

resource "azurerm_linux_virtual_machine" "vuln_sim" {
  count               = var.run_vulnerability == "yes" ? 1 : 0
  name                = "cortex-vuln-sim"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.simulation_nic[0].id]
  
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

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
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
# DESCRIPTION: Streams a verified malware sample directly into a Private Blob.
# WHY IT'S SAFE: Public access is disabled on the storage account, and the 
# file is streamed via pipe to avoid local storage persistence.

resource "azurerm_storage_account" "malware_sim_storage" {
  count                     = var.run_malware == "yes" ? 1 : 0
  name                      = "ctxmalwaresim${random_id.sim_id.hex}"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  public_network_access_enabled = false
}

resource "azurerm_storage_container" "malware_container" {
  count                 = var.run_malware == "yes" ? 1 : 0
  name                  = "malware-sim-container"
  storage_account_name  = azurerm_storage_account.malware_sim_storage[0].name
  container_access_type = "private"
}

resource "terraform_data" "download_malware_azure" {
  count = var.run_malware == "yes" ? 1 : 0

  triggers_replace = [
    azurerm_storage_container.malware_container[0].id
  ]

  provisioner "local-exec" {
    # File name: malaware-sim-file.apk
    # Metadata used for Cortex classification: Cortex-Official-WildFire-Malware-Simulation-Safe
    command = "curl -sL https://wildfire.paloaltonetworks.com/publicapi/test/apk | az storage blob upload --account-name ${azurerm_storage_account.malware_sim_storage[0].name} --container-name ${azurerm_storage_container.malware_container[0].name} --name malaware-sim-file.apk --type block --data @- --auth-mode login --tags Simulation-Type=Cortex-Official-WildFire-Malware-Simulation-Safe"
  }
}