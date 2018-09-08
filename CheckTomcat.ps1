#!/usr/bin/env pwsh

function Get-TomcatInfo {  
	[CmdletBinding()]
	param( 
		[Parameter(Position=1)][string[]]$SshHosts
	)

	$script = Get-Content -Raw "$PSScriptRoot/tomcat_functions"
	$script += "`ncheck_all_tomcats | sed 's/\s\+/,/g'`n"
	
	$results=@()
	foreach ($remote in $SshHosts) {
		$data=ssh $remote $script
		$table=ConvertFrom-Csv $data
		$table | add-member HOST $remote
		$table
		$results+=$table
	}
}

# available properties are HOST, CPU, RSS, VSZ, PORT, STATE, CATALINA_BASE

Get-TomcatInfo "tom@li50-190.members.linode.com"  | format-table -property HOST,CATALINA_BASE,STATE,RSS,VSZ,CPU

