Function Get-TeamCityBuildConfigurations{
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
        $BuildConfigurations = $Project.project.buildTypes.buildType

        if ($BuildConfigurations -ne $null){
            Return $BuildConfigurations
        }

    }
    catch{
        throw $_
    }
}