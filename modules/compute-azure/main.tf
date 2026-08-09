resource "azurerm_public_ip" "app" {
  name                = "pip-${var.project_name}-${var.environment}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static" # required by the Standard SKU
  sku                 = "Standard"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "azurerm_network_interface" "app" {
  name                = "nic-${var.project_name}-${var.environment}-app"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app.id
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  name                = "vm-${var.project_name}-${var.environment}-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [azurerm_network_interface.app.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.os_disk_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # cloud-init script; Azure requires it base64-encoded.
  custom_data = base64encode(templatefile("${path.module}/user_data.sh", {
    admin_username = var.admin_username
    stack_repo_url = var.stack_repo_url
  }))

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
