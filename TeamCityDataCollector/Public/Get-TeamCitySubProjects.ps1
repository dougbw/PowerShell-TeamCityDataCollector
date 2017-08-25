Function Get-TeamCitySubProjects{
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

    # Get projects within a specified project
    $Uri = "{0}/app/rest/projects/id:{1}" -f $BaseUri, $ProjectId
    $Project = Invoke-RestMethod -Uri $Uri -WebSession $WebSession
    Write-Verbose ("Project '{0}' contains '{1}' projects" -f $ProjectId, $Project.project.projects.count)

        if ($Project.project.projects.count -gt 0){

            # Output the list of subprojects, and recursively search each subproject
            $SubProjects = $Project.project.projects.project
            $SubProjects
            foreach ($SubProject in $SubProjects){
                Get-TeamCitySubProjects -BaseUri $BaseUri -ProjectId $SubProject.id -WebSession $WebSession
            }

        }
    }
    catch{
        throw $_
    }

}