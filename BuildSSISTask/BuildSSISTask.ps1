#
# CompileSSISTask.ps1
#
[CmdletBinding(DefaultParameterSetName = 'None')]
param(
[string]$workingFolder = $env:BUILD_SOURCESDIRECTORY
)

Write-Host ("  _____        _     ___ _     _         ")
Write-Host (" |_   _|____ _(_)__ / __| |___| |__  ___ ")
Write-Host ("   | |/ _ \ \ / / _| (_ | / _ \ '_ \/ -_)")
Write-Host ("   |_|\___/_\_\_\__|\___|_\___/_.__/\___|")
Write-Host ("                                         ")
Write-host ("==============================================================================")

Write-Host "Starting BuildSSISTask"
Trace-VstsEnteringInvocation $MyInvocation

#Solution Group
$solnPath            = Get-VstsInput -Name solnPath -Require
$solnCmdSwitch       = Get-VstsInput -Name solnCmdSwitch -Require
$solnConfigName      = Get-VstsInput -Name solnConfigName -Require
#Project Group
$buildProject        = Get-VstsInput -Name buildProject -Require
$projPath            = Get-VstsInput -Name projPath
$projConfigName      = Get-VstsInput -Name projConfigName
#Advanced Group
$devenvVersion       = Get-VstsInput -Name devenvVersion -Require

Write-host ("==============================================================================")
#Format/Initialise Values
switch ($devenvVersion) 
	{ 
		12 {$compiler = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\Devenv.exe"} 
		14 {$compiler = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\Devenv.exe"}
	}
Write-Host ("Denenv.com version: $compiler")
Write-Host ("Working Directory: $workingFolder")

#Test Solution path
if(!(Test-Path $solnPath))
{
	Write-Host "##vso[task.logissue type=error;]Cannot access Solution file path: $solnPath"
} else {
	Write-Host ("Solution file path: $solnPath")
}

#Test Project path
Write-Host ("Project file enabled: $buildProject")
if($buildProject)
{
	if(!(Test-Path $projPath))
	{
		Write-Host "##vso[task.logissue type=error;]Cannot access Project file path: $projPath"
	} else {
		Write-Host ("Project file path: $projPath")
	}
}

#Create Argument List
$argumentList = ("`"$solnPath`" /$solnCmdSwitch $solnConfigName")

#Extend Argument List if Project checkbox eneabled
$buildProject = [System.Convert]::ToBoolean($buildProject)
if($buildProject)
{		
	$argumentList += (" /project `"$projPath`" /projectconfig $projConfigName")
}
Write-Host ("Executing command: $compiler $argumentList")
Write-host ("==============================================================================")

try	{
	#build Solution / Project
	Start-Process $compiler $argumentList -NoNewWindow -PassThru -Wait -Verbose
} catch {
	Write-Host ("##vso[task.logissue type=error;]Task_InternalError "+ $_.Exception.Message)
} finally {
	$outputFile = Get-ChildItem $workingFolder -Recurse -Filter "*.ispac"
	if (!$outputFile)
	{
		Write-Host "##vso[task.logissue type=error;]Test Output: No .ispac file found in $workingFolder!"
	}
	Trace-VstsLeavingInvocation $MyInvocation
}
Write-Host "Ending BuildSSISTask"