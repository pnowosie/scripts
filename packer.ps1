<#
  .SYNOPSIS
    packer.ps1 - Create application package 
    (C) 2014 Pawel Nowosielski
  .DESCRIPTION
    Create ziped binaries package of specified application. You need to provide just project's directory, 
    script will find binaries folder coresponding to given compilation target and compress files into package.
    Script will discover whether project is caried on source control system and name package file matching 
    the rule: {Last Changed Date}_Rev{Last Changed Rev}.zip
    Path to package file will be added to the clipboard for convinient use (e.g. select mail attachment, etc.)

  .PARAMETER Project
    Project name - should match directory name inside $ProjDirRoot directory. It usualy is repository root directory.
	
  .PARAMETER VsProjName
    VS Project dir   - VisualStudio project directory name somewhere in Project dir. Default is the same as Project, but you can specify other for multiprojects solutions. 

  .EXAMPLE
    U:\PS> .\packer.ps1 RepoRoot -VsProjName SlnSubProject

    Creates binaries zip package of specified application. Path to created zip file is added to clipboard.
    This creates file 20140415_171209_Rev604.zip in $PublishRoot\SlnSubProject directory.
  .NOTES
   
#>

param(
	[Parameter(Mandatory=$true, Position=0, ParameterSetName="Project", HelpMessage="Project name (e.g. VS solution")]
	[ValidateNotNullOrEmpty()]
	[string] $Project,
	[string] $VsProjName = $Project
)
&{
	## Script configuration
	Function CopyCmd ($sourceDir, $targetDir) {
		xcopy /S/I/Y /EXCLUDE:"c:\tmp\Published\dot-net-excl.txt" $sourceDir $targetDir
	}

	Function PackCmd ($sourceDir, $targetFilePath) {
		$PackerTool = "C:\Program Files\7-Zip\7z.exe"
		&$PackerTool a -tzip $targetFilePath $sourceDir
	}
	
	Function VCSInfoCmd ($projDir) {
		svn info $projDir | Out-String
	}
	
	$ProjDirRoot = "<your dir here>"       # Pass path to your projects directory
	$PublishRoot = "<your dir here>"       # Pass path where packages should be created
	$TargetCompilation = "Debug"

	## Script start

	$workDir = Join-Path $ProjDirRoot $Project -Resolve
	#echo "workDir: $workDir"
	if (-not (Test-Path $workDir)) {
		throw "No project named: $Project in projects directory."
	}
	
	# Get all subdirectories of given path (notice 'Out-String' to make it regex-able)
	$allProjDirs = ls $workDir -Recurse | ?{ $_.PSIsContainer } | Select-Object FullName | Out-String
	$targetPath = 'Incorrect-Path'
	
	# try to find VS subproject binaries directory of the name '$VsProjName'
	if ($allProjDirs -match ".*\\$VsProjName\\bin[^\\]") {
		$targetPath = $Matches[0].trim()
	}
	# otherwise find any subproject binaries directory
	elseif ($allProjDirs -match ".*\\bin[^\\]") {
		if ($Matches.Count -gt 1) {
			throw "To many matches found for projects binary folder"
		}
		$targetPath = $Matches[0].trim()
	}

	if (-not (Test-Path $targetPath)) {
		throw "No binaries folder for project: $Project found"
	}
	
	$targetBinDir = Join-Path $targetPath $TargetCompilation -Resolve
	if (-not (Test-Path $targetBinDir)) {
		throw "Project [$Project] does not contains compilation target for $TargetCompilation"
	}
	echo "Packaging binaries from: $targetBinDir"
	
	# Prepare project's publish directory
	$copyTempDir = Join-Path $PublishRoot $VsProjName
	if (-not (Test-Path $copyTempDir)) { 
		mkdir $copyTempDir 
	}
	
	# Find required information from source control system
	$vsProjDir = Join-Path $targetBinDir "../.." -Resolve
	$info = VCSInfoCmd $vsProjDir
	
	if ($info) {
		if (-not ($info -match "Last Changed Rev:\s+(\d+)")) { throw "Cannot obtain revision number from source control" }
		$revision = $Matches[1]
		if (-not ($info -match "Last Changed Date:\s+(.*)\s+\(")) { throw "Cannot obtain last modified date from source control" }
		$lmd = $Matches[1] 
		$d= [DateTime]::Parse($lmd).ToString('yyyy-MM-dd HH:mm:ss')
		
		$copyDirName = $d.ToString().Replace("-","").Replace(":","").Replace(" ","_")
		$copyDirName += "_Rev$revision"
	}
	# no source control
	else {
		Write-Warning "Project is not cared on source control system"
	}
	
	if (-not $copyDirName) { 
		$copyDirName = [DateTime]::Now.ToString().Replace("-","").Replace(":","").Replace(" ","_")
		$pubCnt = [int](ls "$copyTempDir\*.zip" | Measure-Object).Count
		$copyDirName += "_Rev" + $pubCnt.ToString("D3")
	}
	
	# Create destination directory and copy files
	$destTempDir = Join-Path $copyTempDir $copyDirName
	if (Test-Path $destTempDir) {
		rm $destTempDir, "$destTempDir.zip" -Recurse -Force
	}
	CopyCmd $targetBinDir $destTempDir
	
	# Create package information file
	$packinfo = "[$([DateTime]::UtcNow.ToString('s'))] $copyDirName $($Env:USERNAME)@$($Env:COMPUTERNAME):$workDir"
	Out-File -FilePath $(Join-Path $destTempDir "packinfo") -InputObject $packinfo.TrimEnd() -Encoding UTF8
	
	# Compression copy temp folder creating package
	$zipPath = Join-Path $copyTempDir "$copyDirName.zip"
	PackCmd $destTempDir $zipPath
	
	echo ""
	echo "[SUCCESS] $packinfo"
	echo "Target package file path was added to clipboard"
	# Adding path to clipboard
	$zipPath | clip
}
