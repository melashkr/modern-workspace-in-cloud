output "vnet-name" {
  value = data.openstack_networking_network_v2.vnet.name
}

output "vm-name" {
  value = openstack_compute_instance_v2.vm_instance_win.name
}
