#-----------------------------------------------------------------
<#  
.Synopsis
		Handy file name generator for logs, package and temporary file 
.Description
		Example use: 
		Just type: 
						> Time-FileName						  - to get string you can use elsewhere
						> "$(Time-FileName).log" 		- to use inside a command
#>
Function Time-FileName
{
	return "{0:yyyyMMdd_HHmmss}" -f (Get-Date)
}
Function Ticks-FileName
{
	return "$((Get-Date).Ticks)"
}
