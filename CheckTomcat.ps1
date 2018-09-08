#!/usr/bin/env pwsh

function Get-TomcatInfo {  
	[CmdletBinding()]
	param( 
		[Parameter(Position=1)][string[]]$SshHosts
	)

	$script = Get-Content -Raw "$PSScriptRoot/tomcat_functions"
	foreach ($remote in $SshHosts) {
		ssh $remote $script
	}

}

Get-TomcatInfo "tom@li50-190.members.linode.com" -Verbose
