resource "azurerm_resource_group" "rgr" {
  location = var.location_name
  name     = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rgr.location
  resource_group_name = azurerm_resource_group.rgr.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rgr.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic_vm" {
  name                = "vnic-vm"
  location            = azurerm_resource_group.rgr.location
  resource_group_name = azurerm_resource_group.rgr.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_vm.id
  }
}

resource "azurerm_public_ip" "pip_vm" {
  name                = "public-ip-vm"
  resource_group_name = azurerm_resource_group.rgr.name
  location            = azurerm_resource_group.rgr.location
  allocation_method   = "Dynamic"
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm"
  resource_group_name = azurerm_resource_group.rgr.name
  location            = azurerm_resource_group.rgr.location
  size                = "Standard_DS1_v2"
  admin_username      = var.ssh_user
  network_interface_ids = [
    azurerm_network_interface.nic_vm.id,
  ]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = file(var.public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name = "8-gen1" 
    product = "almalinux"
    publisher = "almalinux" 
  }

  source_image_reference {
    publisher = "almalinux"
    offer     = "almalinux"
    sku       = "8-gen1"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "securitygroup"
  location            = azurerm_resource_group.rgr.location
  resource_group_name = azurerm_resource_group.rgr.name

  security_rule {
    name                       = "httprule"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "sshrule"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-link" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_kubernetes_cluster" "kc" {
  name                = var.kubernetes_cluster_name
  location            = azurerm_resource_group.rgr.location
  resource_group_name = azurerm_resource_group.rgr.name
  dns_prefix          = "miok8s"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = var.registry_name
  resource_group_name = azurerm_resource_group.rgr.name
  location            = azurerm_resource_group.rgr.location
  sku                 = var.registry_sku
  admin_enabled       = true
}

resource "azurerm_role_assignment" "reg" {
  principal_id                     = azurerm_kubernetes_cluster.kc.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
output "azurerm_kubernetes_cluster" {
  value     = azurerm_kubernetes_cluster.kc.name

}

output "kube_config" {
  value = azurerm_kubernetes_cluster.kc.kube_config_raw

  sensitive = true
}

output "vm_public_ip" {
  value = azurerm_public_ip.pip_vm.ip_address
}

output "ssh_user" {
  value = var.ssh_user
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_admin_user" {
  value     = azurerm_container_registry.acr.admin_username
  sensitive = true
}

output "acr_admin_pass" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}
