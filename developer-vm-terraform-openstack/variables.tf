# Params file for variables

# vm
variable "vm_name" {
  type    = string
  default = "vm-BIDeveloper-dev-010"
}

# win-10-id: 7779cbb5-f035-4c3e-a484-c9def1981345
# ubunut-id: d1761e32-15a5-4301-ac7e-7f98a39d734c
variable "vm_image_id" {
  type    = string
  default = "d1761e32-15a5-4301-ac7e-7f98a39d734c"
}

variable "vm_image_name" {
  type    = string
  default = "Ubuntu-22.04"
}

variable "vm_image_id_win" {
  type    = string
  default = "7779cbb5-f035-4c3e-a484-c9def1981345"
}

#snapshot of windows 10 pro
variable "vm_snp_id_win" {
  type    = string
  default = "6c6248cd-6010-482a-90e6-0dcb34b4d504"
}

variable "vm_snp_id_win_2" {
  type    = string
  default = "38d2215b-9128-49a2-bde5-d45869b3cbdd"
}

# 2 vCPU, 8 GB RAM
variable "vm_flavor_id_m1Max" {
  type    = string
  default = "0ccbe89f-a762-43d7-a335-4ffb72a1c562"
}

# 4 vCpu, 16 GB RAM
variable "vm_flavor_id_m2Xlarge" {
  type    = string
  default = "c25a22cd-d2ea-44ef-853e-2e318ec10830"
}
variable "vm_keypairs" {
  type    = string
  default = "Windows-Key"
}

# vm volume
variable "vm_volume_datdisk_name" {
  type    = string
  default = "DATA-Disk"
}
variable "vm_volume_datadisk_size" {
  type    = number
  default = 500 #250
}
