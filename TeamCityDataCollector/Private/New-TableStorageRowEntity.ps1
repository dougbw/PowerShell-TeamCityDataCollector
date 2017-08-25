function New-TableStorageRowEntity{
[CmdletBinding()]
param(
		
	[Parameter(Mandatory=$true)]
	[AllowEmptyString()]
    [String]
    $PartitionKey,

	[Parameter(Mandatory=$true)]
	[AllowEmptyString()]
    [String]
    $RowKey,

	[Parameter(Mandatory=$true)]
    [PSCustomObject]
    $Properties

)
	try{

	    # Create entity
		$Entity = New-Object -TypeName Microsoft.WindowsAzure.Storage.Table.DynamicTableEntity -ArgumentList $PartitionKey, $RowKey
    
        # Add properties
        $Pattern = "[^a-zA-Z0-9]"
	    foreach ($Property in $Properties.psobject.Properties){
            if ($Property.Value -ne $null){
                $Name = $Property.Name -replace $Pattern,''
		        $Entity.Properties.Add($Name, $Property.Value)
            }
	    }
    
        Return $Entity
    }
    catch{
        throw $_
    }
}
