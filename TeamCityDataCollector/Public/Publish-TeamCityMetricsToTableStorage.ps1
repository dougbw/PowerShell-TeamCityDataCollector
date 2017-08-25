Function Publish-TeamCityMetricsToTableStorage{
[cmdletbinding()]
Param(

    [Parameter(Mandatory = $True)]
    [array]
    $Builds,

    [Parameter(Mandatory = $True)]
    [string]
    $StorageAccountName,

    [Parameter(Mandatory = $True)]
    $StorageAccountKey,

    [Parameter(Mandatory = $False)]
    [string]
    $StorageAccountTableName = "TeamCity"

)

    $StartTime = Get-Date
    $Entities = New-Object -TypeName 'System.Collections.ArrayList'

    try{

        Write-Output ("Starting insert '{0}' rows to table storage" -f $Builds.count)

        $StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
        
        try{
            $StorageAccountTable = Get-AzureStorageTable -Context $StorageContext -Name $StorageAccountTableName -ErrorAction Stop
        }
        catch{
            $StorageAccountTable = New-AzureStorageTable -Context $StorageContext -Name $StorageAccountTableName -ErrorAction Stop
            Write-Verbose ("Created table '{0}'" -f $StorageAccountTableName)
        }
        
        foreach ($Build in $Builds){
            $Entity = New-TableStorageRowEntity -PartitionKey $Build.ProjectId -RowKey $Build.BuildId -Properties $Build
            $Entities.Add($Entity) | Out-Null
        }

        $Insert = Insert-TableStorageRowBatch -StorageAccountTable $StorageAccountTable -Entities $Entities

        $TimeTaken = New-TimeSpan -Start $StartTime -End (Get-Date)
        $SuccessfulRowsCount = $Insert | Where {$_.HttpStatusCode -eq '204'} | Measure-Object | Select -ExpandProperty Count
        $RowsPerSecond = [math]::Round(($SuccessfulRowsCount / $TimeTaken.TotalSeconds),2) 
        Write-Output ("Successfully inserted '{0}' rows to table storage in '{1}' seconds. Rows per second = '{2}'" -f $SuccessfulRowsCount, $TimeTaken.TotalSeconds, $RowsPerSecond  )
    
    }
    catch{
        throw $_
    }

}



