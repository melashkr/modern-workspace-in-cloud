param location string
param networkInterfaceName string
param enableAcceleratedNetworking bool
param networkSecurityGroupName string
param networkSecurityGroupRules array
param subnetName string
param virtualNetworkName string
param addressPrefixes array
param subnets array
param publicIpAddressName string
param publicIpAddressType string
param publicIpAddressSku string
param pipDeleteOption string
param virtualMachineName string
param virtualMachineComputerName string
param virtualMachineRG string
param osDiskType string
param osDiskDeleteOption string
param dataDisks array
param dataDiskResources array
param virtualMachineSize string
param nicDeleteOption string
param adminUsername string

@secure()
param adminPassword string
param patchMode string
param enableHotpatching bool
param securityType string
param secureBoot bool
param vTPM bool
param autoShutdownStatus string
param autoShutdownTime string
param autoShutdownTimeZone string
param autoShutdownNotificationStatus string
param autoShutdownNotificationLocale string

var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var vnetName = virtualNetworkName
var vnetId = resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource networkInterfaceName_resource 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIpAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName)
            properties: {
              deleteOption: pipDeleteOption
            }
          }
        }
      }
    ]
    enableAcceleratedNetworking: enableAcceleratedNetworking
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    networkSecurityGroupName_resource
    virtualNetworkName_resource
    publicIpAddressName_resource
  ]
}

resource networkSecurityGroupName_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: networkSecurityGroupRules
  }
}

resource virtualNetworkName_resource 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
}

resource publicIpAddressName_resource 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: publicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
  sku: {
    name: publicIpAddressSku
  }
}

resource dataDiskResources_name 'Microsoft.Compute/disks@2022-03-02' = [for item in dataDiskResources: {
  name: item.name
  location: location
  properties: item.properties
  sku: {
    name: item.sku
  }
}]

resource virtualMachineName_resource 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        deleteOption: osDiskDeleteOption
      }
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: 'win10-22h2-pro-g2'
        version: 'latest'
      }
      dataDisks: [for item in dataDisks: {
        lun: item.lun
        createOption: item.createOption
        caching: item.caching
        diskSizeGB: item.diskSizeGB
        managedDisk: {
          id: (item.id ?? ((item.name == json('null')) ? json('null') : resourceId('Microsoft.Compute/disks', item.name)))
          storageAccountType: item.storageAccountType
        }
        deleteOption: item.deleteOption
        writeAcceleratorEnabled: item.writeAcceleratorEnabled
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName_resource.id
          properties: {
            deleteOption: nicDeleteOption
          }
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVmAgent: true
        patchSettings: {
          enableHotpatching: enableHotpatching
          patchMode: patchMode
        }
      }
    }
    licenseType: 'Windows_Client'
    securityProfile: {
      securityType: securityType
      uefiSettings: {
        secureBootEnabled: secureBoot
        vTpmEnabled: vTPM
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  identity: {
    type: 'systemAssigned'
  }
  dependsOn: [
    dataDiskResources_name
  ]
}

resource shutdown_computevm_virtualMachineName 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${virtualMachineName}'
  location: location
  properties: {
    status: autoShutdownStatus
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: autoShutdownTime
    }
    timeZoneId: autoShutdownTimeZone
    targetResourceId: virtualMachineName_resource.id
    notificationSettings: {
      status: autoShutdownNotificationStatus
      notificationLocale: autoShutdownNotificationLocale
      timeInMinutes: '30'
    }
  }
}

output adminUsername string = adminUsername