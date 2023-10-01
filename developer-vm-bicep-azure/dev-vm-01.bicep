targetScope = 'resourceGroup'

param vmName string
param vnetName string
param subnetName string
param networkRG string
@description('VM Typ can be dev-vm for developer or bi-vm for bi-developer')
param vmDevType string
param location string

param localAdminUser string = 'admin001'
@secure()
param localAdminPasswd string

var var_computernameWithoutDashes = replace(vmName, '-', '')
var var_computername = substring(var_computernameWithoutDashes, 0, 10)
var var_vmSize = toLower(vmDevType) == 'developer-vm' ? 256 : toLower(vmDevType) == 'bi-developer-vm' ? 500 : 256 // default 256 GB
var var_vmType = toLower(vmDevType) == 'developer-vm' ? 'Standard_D2s_v3' : 'Standard_D4s_v3'

resource pubIPRes 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: 'pubIP-${vmName}'
  location: location
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'

  }
  sku: {
    name: 'Basic'
  }
}

resource nsgRes 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: 'nsg-${vmName}'
  location: location

  properties: {
    securityRules: [
      {
        name: 'Allow_RDP'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          direction: 'Inbound'
          priority: 100
        }
      }
    ]
  }
}

resource vnetExisted 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
  scope: resourceGroup(networkRG)
}

// INFO: That is outbound subnet for traffic of Web Apps which for FSM is subnet 3
resource subnet1OutboundExisted 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  parent: vnetExisted
  name: subnetName
}

resource netif 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: 'netif-${vmName}'
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pubIPRes.id
          }
          subnet: {
            // id: '/subscriptions/${subscriptionId}/resourceGroups/${networkRG}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${subnetName}'
            id: subnet1OutboundExisted.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgRes.id
    }
  }
  dependsOn: []
}

var dataDiskListRes = [
  {
    name: '${vmName}_DataDisk_0'
    sku: 'StandardSSD_LRS'
    properties: {
      diskSizeGB: var_vmSize
      creationData: {
        createOption: 'empty'
      }
    }
  }
]

var dataDisks = [
  {
    lun: 0
    createOption: 'Attach'
    deleteOption: 'Detach'
    caching: 'ReadWrite'
    writeAcceleratorEnabled: false
    //id: null
    name: '${vmName}_DataDisk_0'
    //storageAccountType: null
    diskSizeGB: var_vmSize // INFO: set vm size dynamicaly if dev-vm or bi-vm
    //diskEncryptionSet: null
  }
]

resource dataDiskResources 'Microsoft.Compute/disks@2022-03-02' = [for item in dataDiskListRes: {
  name: item.name
  location: location
  properties: item.properties
  sku: {
    name: item.sku
  }
}]

resource vmDevRes 'Microsoft.Compute/virtualMachines@2023-07-01' = {

  name: vmName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: var_vmType
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
        name: '${vmName}_OsDisk_1'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: [for item in dataDisks: {
        lun: item.lun
        createOption: item.createOption
        caching: 'ReadWrite'
        //writeAcceleratorEnabled: false
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
          id: resourceId('Microsoft.Compute/disks', item.name)
        }
        //deleteOption: 'Detach'
        diskSizeGB: item.diskSizeGB
        toBeDetached: false
      }]
      //diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: var_computername
      adminUsername: localAdminUser
      adminPassword: localAdminPasswd
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
          id: netif.id

          properties: {
            // deleteOption: 'Detach'
            primary: true
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
  dependsOn: [
    dataDiskResources
  ]
}

// resource resManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
//   name: 'vm-managed-identity-001'
//   location: location
// }

var psscriptforAppsUri = 'https://stvmpowerapp01.blob.core.windows.net/ps-scripts/app-to-install.ps1'

resource VmName_autoConfiguration 'Microsoft.Compute/virtualMachines/extensions@2018-06-01' = {
  name: '${vmName}-initconfig'
  location: location
  parent: vmDevRes
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      //INFO: is required
      //url: https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File app-to-install.ps1'
      fileUris: [
        psscriptforAppsUri
      ]
    }
  }
  dependsOn: []
}
