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
        
        .EXAMPLE
        $v = Get-TomcatStats myuser@myhost.com,myuser@myhost2.com
        $v | Where-Object STATE -eq 'UP' | sort-object CPU -Descending | Format-Table

	HOST           STATE RSS   VSZ    CPU LOGSZ CATALINA_BASE        
	----           ----- ---   ---    --- ----- -------------       
	myuser@myhost1 UP    95MiB 2.4GiB 5.2 120K  /home/tom/catalina1 
	myuser@myhost2 UP    95MiB 2.4GiB 3.0 120K  /home/tom/catalina1 

        Filter out all non-running tomcats and sort by CPU usage
	#>
	[CmdletBinding()]
	param( 
		[Parameter(Mandatory=$true,Position=1)][string[]]$SshHosts,
		[string]$SearchPath,
                [switch]$ForcePutty
	)

	$script = Get-Content -Raw "$PSScriptRoot/tomcat_functions"
	$script += "`ncheck_all_tomcats $SearchPath | sed 's/\s\+/,/g'`n"

	# Allow user to force use of PuTTY, which is useful when running locally if you have
	# ssh/scp installed but can't get ssh-add to work because you're in powershell here
	if( $ForcePutty ){
            Write-Verbose "Forcing use of PuTTY..."
            $ssh = Get-Command plink 
	 } else {
            # Find SSH and SCP Commands, preferring "ssh" and "scp" over "plink" and "pscp"
            @("plink", "ssh") |% {
                if( Get-Command $_ -ErrorAction SilentlyContinue) {
                        Write-Verbose "Using $_"
                        $ssh=$_
                }
            }
	}

	$results=@()
	foreach ($remote in $SshHosts) {
		Write-Verbose "Checking $remote..."
		$data=& $ssh $remote $script
		$table=ConvertFrom-Csv $data
		$table | add-member HOST $remote
		$results+=$table
	}
	return $results
}

Export-ModuleMember Get-TomcatStats
