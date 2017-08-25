Function Invoke-TeamCityDataCollector{
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

    [Parameter(Mandatory = $True)]
    [timespan]
    $BuildAgeLimit = "07.00:00:00",

    [Parameter(Mandatory = $True)]
    [ValidateLength(3,24)]
    [string]
    $StorageAccountName,

    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [string]
    $StorageAccountKey,

    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [string]
    $StorageAccountTableName,

    [Parameter(Mandatory = $True)]
    [string]
    $RootProjectId,

    [Parameter(Mandatory = $False)]
    [string]
    $ExportPath = ("TeamCity_{0}_{1}.xml" -f $RootProjectId,(Get-Date -Format "yyyy-MM-dd__HH-mm-ss")),

    [Parameter(Mandatory = $False)]
    [ValidateRange(0,9999)]
    [int]
    $TeamCityThrottleDelayMilliSeconds = 0

)

    begin{
        Write-Verbose ("{0}: Begin Operation '{1}'" -f (Get-Date).ToString(), $MyInvocation.MyCommand)
        $BuildConfigurations = @()
        $Builds = @()
        $StartTime = Get-Date
    }

    process{
        # Start web session
        Invoke-WebRequest -UseBasicParsing -UseDefaultCredentials $BaseUri -SessionVariable WebSession | Out-Null

        # Get project and subprojects
        $RootProject = Get-TeamCityProject -BaseUri $BaseUri -ProjectId $RootProjectId -WebSession $WebSession
        $SubProjects = Get-TeamCitySubProjects -BaseUri $BaseUri -ProjectId $RootProjectId -WebSession $WebSession

        # Get build configurations 
        $BuildConfigurations += Get-TeamCityBuildConfigurations -BaseUri $BaseUri -ProjectId $RootProjectId -WebSession $WebSession
        foreach ($SubProject in $SubProjects){
            Start-Sleep -Milliseconds $TeamCityThrottleDelayMilliSeconds
            $BuildConfigurations += Get-TeamCityBuildConfigurations -BaseUri $BaseUri -ProjectId $SubProject.id -WebSession $WebSession
        }

        # Get builds
        foreach ($BuildConfiguration in $BuildConfigurations){
            Start-Sleep -Milliseconds $TeamCityThrottleDelayMilliSeconds
            $Builds += Get-TeamCityBuilds -BaseUri $BaseUri -BuildConfigurationId $BuildConfiguration.id -WebSession $WebSession -BuildAgeLimit $BuildAgeLimit
        }

        $TeamcityProcessingTime = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Output ("Teamcity data collection processing time = '{0}'" -f $TeamcityProcessingTime)
        Write-Output ("Project '{0}' contains a total of '{1}' projects" -f $RootProjectId, $SubProjects.count)
        Write-Output ("Project '{0}' contains a total of '{1}' build configurations" -f $RootProjectId, $BuildConfigurations.count)
        if ($Builds.count -eq 0){
            Write-Warning ("Project '{0}' contains a total of '{1}' builds since '{2}'" -f $RootProjectId, $Builds.count, (Get-Date).AddDays(-$BuildAgeLimit.TotalDays))
            Break
        }
        else{
            Write-Output ("Project '{0}' contains a total of '{1}' builds since '{2}'" -f $RootProjectId, $Builds.count, (Get-Date).AddDays(-$BuildAgeLimit.TotalDays))
        }
    
        # Export to xml file - this allows the publishing to table to be re-run without collecting the data from teamcity again
        $Builds | Export-Clixml -Path $ExportPath -Depth ([int]::MaxValue) -Force -Verbose -ErrorAction Continue
        Publish-TeamCityMetricsToTableStorage -Builds $Builds -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey -StorageAccountTableName $StorageAccountTableName

    }

    end{
        $TotalProcessingTime = New-TimeSpan -Start $StartTime -End (Get-Date)
        Write-Output ("Total processing time = '{0}'" -f $TotalProcessingTime)
        Write-Verbose ("{0}: End Operation '{1}'" -f (Get-Date).ToString(), $MyInvocation.MyCommand)
    }

}