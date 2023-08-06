data "openstack_networking_network_v2" "vnet" {
  name = "vnet-VMsDeveloper"
}

resource "openstack_compute_instance_v2" "vm_instance_win" {
  name              = var.vm_name
  flavor_id         = var.vm_flavor_id_m2Xlarge
  security_groups   = ["default"]
  availability_zone = "nova"

  block_device {
    uuid                  = var.vm_snp_id_win_2
    source_type           = "snapshot"
    destination_type      = "volume"
    delete_on_termination = true
  }
  # metadata = {
  #   admin_pass = "MyP@$$w0rd"
  # }
  network {
    name = data.openstack_networking_network_v2.vnet.name
  }

  user_data = <<-USERDATA
    #ps1_sysnative
     if (!(Test-Path -Path C:\temp )) {
     New-Item -ItemType directory -Path C:\temp
    }
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;

    $installTime = Measure-Command {
      # install chocoloty
      iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
      # install notepade++
      choco install notepadplusplus.install --version=8.1.3 -y;
      # install vscode
      choco install vscode -y;
      # install apache
      choco install apache-httpd -y;
      # install chrome 
      choco install googlechrome -y
    }
    $installTime.TotalMinutes | Out-File -FilePath C:\temp\install_time_total_min.txt
  USERDATA
  # second variant read ps commands from file
  # user_data = "${file("test.sh")}"
}

resource "openstack_networking_floatingip_v2" "floatip_2" {
  pool = "provider"
}

resource "openstack_compute_floatingip_associate_v2" "floatip_2" {
  floating_ip = openstack_networking_floatingip_v2.floatip_2.address
  instance_id = openstack_compute_instance_v2.vm_instance_win.id
}

#attach volume
resource "openstack_blockstorage_volume_v2" "volume_datadisk" {
  name = "${var.vm_name}_${var.vm_volume_datdisk_name}"
  size = var.vm_volume_datadisk_size
}

resource "openstack_compute_volume_attach_v2" "volume_attachment_1" {
  instance_id = openstack_compute_instance_v2.vm_instance_win.id
  volume_id   = openstack_blockstorage_volume_v2.volume_datadisk.id
}
