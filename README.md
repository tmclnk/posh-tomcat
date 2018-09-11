# Powershell Apache Tomcat Monitor
This is a simple script that uses ssh-agents and powershell to aggregate simple information about linux-hosted Apache Tomcat instances.  You'll need SSH and, preferably, an [ssh-agent](https://www.ssh.com/ssh/agent) running, with your keys `ssh-add`ed to it.

Basic Usage:
```Powershell
PS1> Start-SshAgent
PS1> Ssh-AddKey id_rsa
PS1> .\CheckTomcat.ps1 tom@myhost1.com,tom@myhost2.com
HOST            CATALINA_BASE       STATE RSS   VSZ    CPU LOGSZ
----            -------------       ----- ---   ---    --- -----
tom@myhost1.com /home/tom/catalina1 UP    95MiB 2.4GiB 0.0 120K 
tom@myhost1.com /tmp/mycatalina1    DOWN  ?     ?      ?   4.0K 
tom@myhost2.com /home/tom/catalina1 UP    95MiB 2.4GiB 0.0 120K 
```

## Using SSH Agents
### Windows
If you are using Windows 10 with the Windows 10 April 2018 update, you have ssh built in to your shell.  

If not, you can use older (0.7.x) [Posh-Git](https://github.com/dahlbyk/posh-git) releases, which have some convenient cmdlets (namely `start-sshagent` and `ssh-addkey`).
```
PS1> Install-Module posh-git -Scope CurrentUser -MaximumVersion 0.9 -AllowClobber
PS1> Start-SshAgent
PS1> Ssh-AddKey yourkey
PS1> .\CheckTomcat.ps1 tom@myhost1.com,tom@myhost2.com
```

There is additional git-related baggage here (obviously), but if you use Git, you'll want to have Posh-Git anyhow.

### Pageant/PuTTY
You can pass the -ForcePutty switch to if you have your keys loaded into [Pageant](https://www.chiark.greenend.org.uk/~sgtatham/putty/).
```
PS1> .\CheckTomcat.ps1 -ForcePutty tom@myhost1.com,tom@myhost2.com
```

## Using CheckTomcat.ps1
CheckTomcat.ps1 is a simple wrapper that will dump output into a table.  With an ssh-agent running and a key already added to it, you can run it thusly:
```PowerShell
PS1> .\CheckTomcat.ps1 tom@myhost1.com,tom@myhost2.com
HOST            CATALINA_BASE       STATE RSS   VSZ    CPU LOGSZ
----            -------------       ----- ---   ---    --- -----
tom@myhost1.com /home/tom/catalina1 UP    95MiB 2.4GiB 0.0 120K 
tom@myhost1.com /tmp/mycatalina1    DOWN  ?     ?      ?   4.0K 
tom@myhost2.com /home/tom/catalina1 UP    95MiB 2.4GiB 0.0 120K 
tom@myhost2.com /tmp/mycatalina1    DOWN  ?     ?      ?   4.0K 
```

## Using the Module
```PowerShell
PS1> Import-Module -Force ./TomcatMon.psm1
```

`Get-TomcatStats` will return an array of objects, one for each tomcat instance.
```PowerShell
PS1> Get-TomcatStats tom@myhost1.com,tom@myhost2.com

STATE         : UP
PID           : 1048
PORT          : 8282
VSZ           : 2.4GiB
RSS           : 95MiB
CPU           : 0.0
START         : Sep03
LOGSZ         : 120K
CATALINA_BASE : /home/tom/catalina1
HOST          : tom@myhost1.com

STATE         : DOWN
PID           : ?
PORT          : 8080
VSZ           : ?
RSS           : ?
CPU           : ?
START         : ?
LOGSZ         : 4.0K
CATALINA_BASE : /tmp/mycatalina1
HOST          : tom@myhost1.com

STATE         : UP
PID           : 1048
PORT          : 8282
VSZ           : 2.4GiB
RSS           : 95MiB
CPU           : 0.0
START         : Sep03
LOGSZ         : 120K
CATALINA_BASE : /home/tom/catalina1
HOST          : tom@myhost2.com

STATE         : DOWN
PID           : ?
PORT          : 8080
VSZ           : ?
RSS           : ?
CPU           : ?
START         : ?
LOGSZ         : 4.0K
CATALINA_BASE : /tmp/mycatalina1
HOST          : tom@myhost2.com
```

If you aren't further processing the input, then use `Format-Table`
```PowerShell
# the -Property definition here is optional
PS1> Get-TomcatStats tom@myhost1.com,tom@myhost2.com | Format-Table -Property HOST,CATALINA_BASE,STATE,RSS,VSZ,CPU,LOGSZ

HOST            CATALINA_BASE       STATE RSS   VSZ    CPU LOGSZ
----            -------------       ----- ---   ---    --- -----
tom@myhost1.com /home/tom/catalina1 UP    95MiB 2.4GiB 0.0 120K 
tom@myhost1.com /tmp/mycatalina1    DOWN  ?     ?      ?   4.0K 
tom@myhost2.com /home/tom/catalina1 UP    95MiB 2.4GiB 0.0 120K 
tom@myhost2.com /tmp/mycatalina1    DOWN  ?     ?      ?   4.0K 
```

You use normal powershell cmdlets to sort and filter output, e.g.
```PowerShell
$v = Get-TomcatStats myuser@myhost.com,myuser@myhost2.com
$v | Where-Object STATE -eq 'UP' | sort-object CPU -Descending | Format-Table

HOST           STATE RSS   VSZ    CPU LOGSZ CATALINA_BASE        
----           ----- ---   ---    --- ----- -------------       
myuser@myhost1 UP    95MiB 2.4GiB 5.2 120K  /home/tom/catalina1 
myuser@myhost2 UP    95MiB 2.4GiB 3.0 120K  /home/tom/catalina1 
```


## Help
```
NAME
    Get-TomcatStats

SYNOPSIS
    Returns information about tomcat instances on remote SSH hosts.


SYNTAX
    Get-TomcatStats [-SshHosts] <String[]> [-SearchPath <String>] [-ForcePutty] [<CommonParameters>]


DESCRIPTION
    Returns a combined list of status objects.  Each object will have the following members:

    HOST
    CATALINA_BASE
    STATE <UP|DOWN>
    RSS Resident State Size (allocated memory, excluding swap; human readable)
    VSZ Virtual Memory Size (total available)
    CPU pct usage at time of sample
    LOGSZ Total Size of $CATALINA_BASE/logs (human readable)


RELATED LINKS

REMARKS
    To see the examples, type: "get-help Get-TomcatStats -examples".
    For more information, type: "get-help Get-TomcatStats -detailed".
    For technical information, type: "get-help Get-TomcatStats -full".
```
