





# Create private network interface1
resource "azurerm_network_interface" "private_nic" {
  name                          = "Private_myNIC"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  
  
  ip_configuration {
    name                          = "myNICConfg-private"
    subnet_id                     = azurerm_subnet.subnet[1].id
    private_ip_address_allocation = "dynamic"
  }
}



# Create private network interface1

resource "azurerm_network_interface" "private_nic2" {
  name                          = "Private_myNIC2"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  
  ip_configuration {
    name                          = "myNICConfg2-private"
    subnet_id                     = azurerm_subnet.subnet[1].id
    private_ip_address_allocation = "dynamic"
  }
}


# Create private network interface3
resource "azurerm_network_interface" "private_nic3" {
  name                          = "Private_myNIC3"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
 
  ip_configuration {
    name                          = "myNICConfg3-private"
    subnet_id                     = azurerm_subnet.subnet[1].id
    private_ip_address_allocation = "dynamic"
  }
}







# Create private lb
resource "azurerm_lb" "privateLB" {
  name                = "Private_LoadBalancer"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                          = "PrivateIPAddress"
    subnet_id                     = azurerm_subnet.subnet[1].id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
    
 }
}

# Create private lb backend address pool
resource "azurerm_lb_backend_address_pool" "backend_address_pool_private" {
  loadbalancer_id = azurerm_lb.privateLB.id
  name            = "PrivateBackEndAddressPool"
}


# Associate private network interface1 to private lb backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "private_nic_back_association" {
  network_interface_id    = azurerm_network_interface.private_nic.id
  ip_configuration_name   = azurerm_network_interface.private_nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_private.id
}
# Associate private network interface2 to private lb backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "private_nic2_back_association" {##### ???? ?????? ????????
  network_interface_id    = azurerm_network_interface.private_nic2.id
  ip_configuration_name   = azurerm_network_interface.private_nic2.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_private.id
}
# Associate private network interface3 to private lb backend address pool
resource "azurerm_network_interface_backend_address_pool_association" "private_nic3_back_association" {##### ???? ?????? ????????
  network_interface_id    = azurerm_network_interface.private_nic3.id
  ip_configuration_name   = azurerm_network_interface.private_nic3.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_address_pool_private.id
}


# Create Private lb probe
resource "azurerm_lb_probe" "private_lb_probe" {
    name = "tcpProbe"
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id     = azurerm_lb.privateLB.id
    protocol            = "Tcp"
    port                = 5432
    interval_in_seconds = 5
    number_of_probes    = 2
  
}


# Create lb rule
resource "azurerm_lb_rule" "private_LB_rule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.privateLB.id
  name                           = "private_LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 5432
  backend_port                   = 5432
  frontend_ip_configuration_name = azurerm_lb.privateLB.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.private_lb_probe.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_address_pool_private.id
}


# Create lb nat rule
resource "azurerm_lb_nat_rule" "lb_nat_rule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.privateLB.id
  name                           = "SSHAccess"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_lb.privateLB.frontend_ip_configuration[0].name
}




# Create Private availability set
resource "azurerm_availability_set" "private_availability_set" {
  name                = "private-aset"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

}




# Create Private Network Security Group and rule
resource "azurerm_network_security_group" "private_nsg" {
  name                = "private_myTFNSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

 security_rule {
    name                       = "Postgres"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
	 
   }
   security_rule {
    name                       = "SSH2"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}









#Associate private network interface to subnet_network_security_group
resource "azurerm_network_interface_security_group_association" "private_nsg_nic" {
  network_interface_id      = azurerm_network_interface.private_nic.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}


#Associate private network interface2 to subnet_network_security_group
resource "azurerm_network_interface_security_group_association" "private_nsg_nic2" {
  network_interface_id      = azurerm_network_interface.private_nic2.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}

#Associate private network interface3 to subnet_network_security_group
resource "azurerm_network_interface_security_group_association" "private_nsg_nic3" {
  network_interface_id      = azurerm_network_interface.private_nic3.id
  network_security_group_id = azurerm_network_security_group.private_nsg.id
}


# Create Private a Linux virtual machine 
resource "azurerm_virtual_machine" "private_vm" {
  name                   = "privateMyTFVM"
  location               = var.location
  resource_group_name    = azurerm_resource_group.rg.name
  availability_set_id    = azurerm_availability_set.private_availability_set.id 
  network_interface_ids  = [azurerm_network_interface.private_nic.id]
  vm_size                = var.public_vm_size
 

  storage_os_disk {
    name              = "privateMyOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
    
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "privateMyTFVM"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Create Private a Linux virtual machine 2
resource "azurerm_virtual_machine" "private_vm2" {
  name                   = "privateMyTFVM2"
  location               = var.location
  resource_group_name    = azurerm_resource_group.rg.name
  network_interface_ids  = [azurerm_network_interface.private_nic2.id]
  vm_size                = var.public_vm_size
  availability_set_id    = azurerm_availability_set.private_availability_set.id 

  storage_os_disk {
    name              = "privateMyOsDisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
    
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "privateMyTFVM2"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}




# Create Private a Linux virtual machine 3
resource "azurerm_virtual_machine" "private_vm3" {
  name                   = "privateMyTFVM3"
  location               = var.location
  resource_group_name    = azurerm_resource_group.rg.name
  network_interface_ids  = [azurerm_network_interface.private_nic3.id]
  vm_size                = var.public_vm_size
  availability_set_id    = azurerm_availability_set.private_availability_set.id 

  storage_os_disk {
    name              = "privateMyOsDisk3"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
    
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "privateMyTFVM3"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}


#Get data from lb
data "azurerm_lb" "private_data_lb" {
  name                = azurerm_lb.privateLB.name
  resource_group_name = var.resource_group_name
}
#Get data from backend address pool
data "azurerm_lb_backend_address_pool" "private_data_pool" {
  name            = azurerm_lb_backend_address_pool.backend_address_pool_private.name
  loadbalancer_id = data.azurerm_lb.private_data_lb.id
}

