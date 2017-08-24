#
# ExampleTask.ps1
#
[CmdletBinding(DefaultParameterSetName = 'None')]
param()
Trace-VstsEnteringInvocation $MyInvocation

try {
    # Import the localized strings.
    Import-VstsLocStrings "$PSScriptRoot\Task.json"

    Write-Host ("  _____        _     ___ _     _         ")
    Write-Host (" |_   _|____ _(_)__ / __| |___| |__  ___ ")
    Write-Host ("   | |/ _ \ \ / / _| (_ | / _ \ '_ \/ -_)")
    Write-Host ("   |_|\___/_\_\_\__|\___|_\___/_.__/\___|")
    Write-Host ("                                         ")
    Write-host ("==============================================================================")

    Write-Host (Get-VstsLocString -Key StartingTask)

    $ProjectFilePath = Get-VstsInput -Name ProjectFilePath -Require
    $ProjectName = Get-VstsInput -Name ProjectName -Require
    $ServerName = Get-VstsInput -Name ServerName -Require
    $CatalogName = Get-VstsInput -Name CatalogName -Require
    $FolderName = Get-VstsInput -Name FolderName -Require
    $FolderDescription = Get-VstsInput -Name FolderDescription
    $ProjectParameters = Get-VstsInput -Name ProjectParameters

    $sqlConnectionString = "Data Source=$ServerName;Initial Catalog=master;Integrated Security=SSPI;"
    Write-Host (Get-VstsLocString -Key ConnectionString0 -ArgumentList $sqlConnectionString)

    # Test project file path
    if(!(Test-Path $projectFilePath))
    {
        Write-Error (Get-VstsLocString -Key ProjectFile0AccessDenied -ArgumentList $ProjectFilePath)
    } else {
        Write-Host (Get-VstsLocString -Key ProjectFile0 -ArgumentList $ProjectFilePath)
    }

    # Load the IntegrationServices Assembly
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.IntegrationServices") | Out-Null;
    
    # Create a connection object based on the connection string
    # This connection will be used to connect to the Integration services service
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $sqlConnectionString
    
    # Let's create a new Integration Services object based on the SSIS name space and 
    # the connection object created in the previous step
    $integrationServices = New-Object Microsoft.SqlServer.Management.IntegrationServices.IntegrationServices $sqlConnection

    $catalog = $integrationServices.Catalogs[$CatalogName]
    Write-Host $catalog

    # Check if folder exists or create otherwise
    $folder = $catalog.Folders[$FolderName]
    if (-not $folder) {
        Write-Host (Get-VstsLocString -Key CreateFolder0 -ArgumentList $FolderName)
        $folder = New-Object Microsoft.SqlServer.Management.IntegrationServices.CatalogFolder ($catalog, $FolderName, $FolderDescription)
        $folder.Create()
        Write-Host (Get-VstsLocString -Key Folder0Created -ArgumentList $FolderName)
    }
    else {
        Write-Host (Get-VstsLocString -Key Folder0Exists -ArgumentList $FolderName)
    }
    
    # Deploy the project
    Write-Host (Get-VstsLocString -Key DeployingProject0 -ArgumentList $ProjectName)

    [byte[]] $projectFile = [System.IO.File]::ReadAllBytes($ProjectFilePath)
    $folder.DeployProject($ProjectName, $projectFile)
    Write-Host (Get-VstsLocString -Key Project0DeploySuccess -ArgumentList $ProjectName)

    # Set project parameters
    Write-Host (Get-VstsLocString -Key SetParameters)
    $project = $folder.Projects[$ProjectName]
    if ($project.Parameters.Count -neq 0) {
    	$parameterLines = $ProjectParameters -split '[\r\n]'
    	foreach ($parameterLine in $parameterLines) {
        	$parameter = $parameterLine -split '='

        	if ($project.Parameters.Contains($parameter[0])) {
            	Write-Host (Get-VstsLocString -Key SettingParameter0ValueTo1 -ArgumentList $parameter[0],$parameter[1])

            	$project.Parameters[$parameter[0]].Set(
                	$project.Parameters[$parameter[0]].ValueType,
                	$parameter[1]
            	)
        	}
        	else {
	            Write-Warning (Get-VstsLocString -Key Parameter0NotValid -ArgumentList $parameter[0])
	        }
	    }
    }
    $project.Alter()

} catch {
    Write-Error (Get-VstsLocString -Key InternalError0 -ArgumentList $_.Exception.Message)
} finally {
	Trace-VstsLeavingInvocation $MyInvocation
}

Write-Host (Get-VstsLocString -Key EndingTask)
