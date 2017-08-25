[cmdletbinding()]
Param(

    [Parameter(Mandatory = $True)]
    [ValidateScript({
      # Check if valid Uri
        $IsValidUri = [system.uri]::IsWellFormedUriString($_,[System.UriKind]::Absolute)
        if ($IsVAlidUri -eq $True){
            return $True
        }
        else{
            throw "Parameter value is not valid '$_'"
        }
    })]
    [string]
    $BaseUri,

    [Parameter(Mandatory = $False)]
    [timespan]
    $BuildAgeLimit = "01.01:00:00",

    [Parameter(Mandatory = $True)]
    [string]
    $StorageAccountName,

    [Parameter(Mandatory = $True)]
    [string]
    $StorageAccountKey,

    [Parameter(Mandatory = $False)]
    [string]
    $StorageAccountTableName = "TeamCity",

    [Parameter(Mandatory = $False)]
    [string]
    $RootProjectId = "_Root"


)

Import-Module -Name TeamCityDataCollector -Force -ErrorAction Stop -Verbose:$false

Invoke-TeamCityDataCollector -BaseUri $BaseUri -BuildAgeLimit $BuildAgeLimit -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -StorageAccountTableName $StorageAccountTableName -RootProjectId $RootProjectId
