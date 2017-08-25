Function Format-BuildProperties{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $Build,

        [Parameter(Mandatory=$true)]
        $BuildStatisticsToExport 
    
    )
        $BuildStartDate = [datetime]::ParseExact($Build.startDate,$DateTimeFormat, $null)
        $BuildFinishDate = [datetime]::ParseExact($Build.finishDate,$DateTimeFormat, $null)
        $BuildDuration = New-TimeSpan -Start $BuildStartDate -End $BuildFinishDate
        $BuildProperties = [ordered]@{
            ProjectName = $Build.buildType.projectName
            #ProjectNameShort = ($Build.buildType.projectName.Split('::')[-1] -replace '\s')
            ProjectId = $Build.buildType.projectId
            BuildConfigurationName = $Build.buildType.name
            BuildConfigurationId = $Build.buildType.id
            BuildId = $Build.id
            BuildNumber = $Build.number
            BuildStatus = $Build.status
            BuildState = $Build.state
            BuildStartDate = $BuildStartDate
            BuildFinishDate = $BuildFinishDate
            BuildDurationSeconds = [int]$BuildDuration.TotalSeconds
            BuildDurationMinutes = [double]([math]::Round(($BuildDuration.TotalSeconds / 60), 2))
            BuildAgent = $Build.agent.name
            BuildBranch = $Build.branchName
        }

        if ($Build.statistics){
            foreach ($Statistic in ($Build.statistics.property | Where {$_.name -in $BuildStatisticsToExport})){
                $BuildProperties."BuildStatisics$($Statistic.name)" = [int]$Statistic.value 
            }
        }

        Return [pscustomobject]$BuildProperties
    
    }