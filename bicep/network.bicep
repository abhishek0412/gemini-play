param location string = resourceGroup().location

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'gemini-play-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}
