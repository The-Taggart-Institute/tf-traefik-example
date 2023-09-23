resource "azurerm_linux_virtual_machine" "my-wordpress" {
  name                            = "my-wordpress"
  location                        = "westus2"
  resource_group_name             = var.resource_group
  network_interface_ids           = [azurerm_network_interface.my-wordpress.id]
  size                            = "Standard_B1ms"
  computer_name                   = "my-wordpress"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "my-wordpress-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 50
  }


  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = self.public_ip_address
  }
  

  provisioner "file" {
    source     = "../Docker/"
    destination = "/tmp"
  }
  
  provisioner "remote-exec" {
    script = "../setup.sh"
  }
}

resource "azurerm_network_interface" "my-wordpress" {
  name                = "my-wordpress"
  location            = "westus2"
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "my-internal"
    subnet_id                     = azurerm_subnet.my-internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my-wordpress.id
  }
}

resource "azurerm_network_security_group" "my-wordpress" {
  name                = "my-wordpress-nsg"
  location            = "westus2"
  resource_group_name = var.resource_group

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh_source_address
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-http"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "my-wordpress" {
  network_interface_id      = azurerm_network_interface.my-wordpress.id
  network_security_group_id = azurerm_network_security_group.my-wordpress.id
}

resource "azurerm_public_ip" "my-wordpress" {
  name                = "my-wordpress-public-ip"
  location            = "westus2"
  resource_group_name = var.resource_group
  allocation_method   = "Dynamic"
}

resource "azurerm_dns_a_record" "example" {
  name                = "@"
  zone_name           = var.dns_zone
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_linux_virtual_machine.my-wordpress.public_ip_address]
}


output "public_ip" {
  value       = azurerm_linux_virtual_machine.my-wordpress.public_ip_address
  sensitive   = false
  description = "my Public IP"
}
