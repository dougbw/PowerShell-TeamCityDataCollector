Function Get-TeamCityBuilds{
[cmdletbinding()]
Param(

    [Parameter(Mandatory = $True)]
    [string]
    $BaseUri,

    [Parameter(Mandatory = $True)]
    [string]
    $BuildConfigurationId,

    [Parameter(Mandatory = $False)]
    [ValidateRange(10,9999)]
    [int]
    $Count = 1000,

    [Parameter(Mandatory = $False)]
    [string]
    $Fields = "build(id,number,state,status,startDate,finishDate,branchName,buildType(id,name,projectName,projectId),agent(name),statistics(property(name,value)))",

    [Parameter(Mandatory = $True)]
    $WebSession,

    [Parameter(Mandatory = $False)]
    [timespan]
    $BuildAgeLimit = "01.00:00:00"

)

    $BuildStatisticsToExport = @(
        "FailedTestCount"
        "PassedTestCount"
        "TotalTestCount"
        "IgnoredTestCount"
        "TimeSpentInQueue"
        "VisibleArtifactsSize"
    )

    $DateTimeFormat = "yyyyMMdd\THHmmsszzz"
    Add-Type -AssemblyName System.Web
    $ListOfBuilds = New-Object -TypeName 'System.Collections.ArrayList'
    $SinceDate = (Get-Date).AddHours(-$BuildAgeLimit.TotalHours)
    $SinceDateFormatted = Get-Date -Date $SinceDate -Format yyyyMMddThhmmsszz00

    Write-Verbose ("Processing build configuration '{0}'" -f $BuildConfigurationId)
    $Uri = "{0}/app/rest/builds?locator=buildType:{1},branch:(default:any),canceled:any,failedToStart:any,sinceDate:{2},count:{3}&fields={4}" -f  $BaseUri, $BuildConfigurationId, [System.Web.HttpUtility]::UrlEncode($SinceDateFormatted), $Count, $Fields
    $Builds = Invoke-RestMethod -Uri $Uri -WebSession $WebSession
    Write-Verbose ("Build configuration '{0}' contains '{1}' builds" -f $BuildConfigurationId, [int]$Builds.builds.build.count)

    foreach ($Build in $Builds.builds.build){
        Write-Debug ("Build id {0}" -f $Build.id)        
        $BuildData = Format-BuildProperties -Build $Build -BuildStatisticsToExport $BuildStatisticsToExport   
        $ListOfBuilds.add([pscustomobject]$BuildData) | Out-Null
    }

    if ($ListOfBuilds.count -gt 0){
        Return $ListOfBuilds    
    }
}