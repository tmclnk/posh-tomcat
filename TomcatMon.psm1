function Get-TomcatStats {
	<#
	.SYNOPSIS
	Returns information about tomcat instances on remote SSH hosts.
	.DESCRIPTION
	Returns a combined list of status objects.  Each object will have the following members:

	HOST 
	CATALINA_BASE 
	STATE <UP|DOWN>
	RSS Resident State Size (allocated memory, excluding swap; human readable)
	VSZ Virtual Memory Size (total available)
	CPU pct usage at time of sample
	LOGSZ Total Size of $CATALINA_BASE/logs (human readable)

	.PARAMETER SshHosts
	List of SSH-accessible hosts.  You should use an SSH Agent (ssh-agent) for these hosts to allow passwordless
	access.  If the ssh client doesn't connect automatically to a host in the list, a password prompt will appear.
	.EXAMPLE
	Get-TomcatStats myuser@myhost1.com,myuser@myhost2.com
	.EXAMPLE
	Get-TomcatStats myuser@myhost.com,myuser@myhost2.com | format-table -property HOST,CATALINA_BASE,STATE,RSS,VSZ,CPU,LOGSZ

	HOST           CATALINA_BASE       STATE RSS   VSZ    CPU LOGSZ
	----           -------------       ----- ---   ---    --- -----
	myuser@myhost1 /home/tom/catalina1 UP    95MiB 2.4GiB 0.0 120K 
	myuser@myhost1 /tmp/mycatalina1    DOWN  ?     ?      ?   4.0K 
	myuser@myhost2 /home/tom/catalina1 UP    95MiB 2.4GiB 0.0 120K 
	myuser@myhost2 /tmp/mycatalina1    DOWN  ?     ?      ?   4.0K 

	#>
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

# Get-TomcatStats "tom@li50-190.members.linode.com"  | format-table -property HOST,CATALINA_BASE,STATE,RSS,VSZ,CPU,LOGSZ

