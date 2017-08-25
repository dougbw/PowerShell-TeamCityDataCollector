function Insert-TableStorageRowBatch{
[CmdletBinding()]
param(
	[Parameter(Mandatory=$true)]
	$StorageAccountTable,

	[Parameter(Mandatory=$true)]
    [PSCustomObject]
    $Entities,

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

        $Batches = @{}
        $Counter = 0
        $Groups = $Entities | Group-Object -Property PartitionKey

        foreach ($Group in $Groups){
            $Counter++            
            Write-Progress -Activity ("Writing to table storage - {0}/{1}" -f $counter,$Groups.Count) -CurrentOperation $Group.Name -PercentComplete (($Counter / $Groups.Count) * 100) -Status $Group.Name -Id 1

            foreach ($Entity in $Group.Group){

                if ($Batches.ContainsKey($Entity.PartitionKey) -eq $false){
                    $Batches.Add($Entity.PartitionKey, (New-Object Microsoft.WindowsAzure.Storage.Table.TableBatchOperation))
                }

                $Batch = $Batches[$Entity.PartitionKey]
                $Batch.Add([Microsoft.WindowsAzure.Storage.Table.TableOperation]::InsertOrReplace($Entity))
                
                # Batch operations support a maximum of 100 entities
                if ($Batch.Count -eq 100){
                    $StorageAccountTable.CloudTable.ExecuteBatch($Batch)
                    Write-Verbose ("Inserted '{0}' rows to table storage. PartitionKey = '{1}'" -f $batch.count, $Entity.PartitionKey)
                    $batches[$entity.PartitionKey] = (New-Object Microsoft.WindowsAzure.Storage.Table.TableBatchOperation)
                }
        
            }

        $StorageAccountTable.CloudTable.ExecuteBatch($Batch)
        Write-Verbose ("Inserted '{0}' rows to table storage. PartitionKey = '{1}'" -f $Batch.count, $Group.Name)


        }

    }
    catch{
        throw $_
    }
}
