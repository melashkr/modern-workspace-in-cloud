param virtualMachines_vm_dem_001_name string = 'vm-dem-001'
param disks_vm_dem_001_OsDisk_1_05608e70e9f6417497117c361465e843_externalid string = '/subscriptions/your-subscription-id/resourceGroups/rg-poc-vmwithpowerapp/providers/Microsoft.Compute/disks/vm-dem-001_OsDisk_1_05608e70e9f6417497117c361465e843'
param disks_vm_dem_001_DataDisk_0_externalid string = '/subscriptions/your-subscription-id/resourceGroups/rg-poc-vmwithpowerapp/providers/Microsoft.Compute/disks/vm-dem-001_DataDisk_0'
param networkInterfaces_vm_dem_001923_externalid string = '/subscriptions/your-subscription-id/resourceGroups/rg-poc-vmwithpowerapp/providers/Microsoft.Network/networkInterfaces/vm-dem-001923'

resource virtualMachines_vm_dem_001_name_resource 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: virtualMachines_vm_dem_001_name
  location: 'westeurope'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: 'win10-22h2-pro-g2'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${virtualMachines_vm_dem_001_name}_OsDisk_1_05608e70e9f6417497117c361465e843'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
          id: disks_vm_dem_001_OsDisk_1_05608e70e9f6417497117c361465e843_externalid
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: [
        {
          lun: 0
          name: '${virtualMachines_vm_dem_001_name}_DataDisk_0'
          createOption: 'Attach'
          caching: 'ReadOnly'
          writeAcceleratorEnabled: false
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
            id: disks_vm_dem_001_DataDisk_0_externalid
          }
          deleteOption: 'Detach'
          diskSizeGB: 256
          toBeDetached: false
        }
      ]
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: virtualMachines_vm_dem_001_name
      adminUsername: 'admin01'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
        enableVMAgentPlatformUpdates: false
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_vm_dem_001923_externalid
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    licenseType: 'Windows_Client'
  }
}
