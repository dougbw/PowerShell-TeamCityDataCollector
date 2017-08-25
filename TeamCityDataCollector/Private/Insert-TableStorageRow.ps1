function Insert-TableStorageRow{
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true)]
	$StorageAccountTable,
		
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
    $Properties,

	[Parameter(Mandatory=$false)]
    [ValidateSet(
        "Insert",
        "InsertOrMerge",
        "InsertOrReplace"
    )]
    [string]
    $InsertMode = "InsertOrReplace"

)
	try{

	    # Create entity
		$entity = New-Object -TypeName Microsoft.WindowsAzure.Storage.Table.DynamicTableEntity -ArgumentList $PartitionKey, $RowKey
    
        # Add properties
        $Pattern = "[^a-zA-Z0-9]"
	    foreach ($Property in $Properties.psobject.Properties){
            if ($Property.Value -ne $null){
                $Name = $Property.Name -replace $Pattern,''
		        $entity.Properties.Add($Name, $Property.Value)
            }
	    }
    
        # Execute
        switch($InsertMode){
            "Insert"{
                $Response = $StorageAccountTable.CloudTable.Execute([Microsoft.WindowsAzure.Storage.Table.TableOperation]::Insert($entity))
            }
            "InsertOrMerge"{
                $Response = $StorageAccountTable.CloudTable.Execute([Microsoft.WindowsAzure.Storage.Table.TableOperation]::InsertOrMerge($entity))
            }
            "InsertOrReplace"{
                $Response = $StorageAccountTable.CloudTable.Execute([Microsoft.WindowsAzure.Storage.Table.TableOperation]::InsertOrReplace($entity))            
            }
        }

        $Response = $StorageAccountTable.CloudTable.Execute([Microsoft.WindowsAzure.Storage.Table.TableOperation]::InsertOrReplace($entity))
       	return $Response

    }
    catch{
        throw $_
    }
}
