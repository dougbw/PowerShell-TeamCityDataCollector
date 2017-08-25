Function Get-TeamCityProject{
[cmdletbinding()]
Param(

    [Parameter(Mandatory = $True)]
    [string]
    $BaseUri,

    [Parameter(Mandatory = $True)]
    [string]
    $ProjectId,

    [Parameter(Mandatory = $True)]
    $WebSession

)

    try{
        $Uri = "{0}/app/rest/projects/id:{1}" -f $BaseUri, $ProjectId
        $Project = Invoke-RestMethod -Uri $Uri -WebSession $WebSession
        Return $Project
    }
    catch{
        throw $_
    }

}