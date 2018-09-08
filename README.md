# Powershell Apache Tomcat Monitor
This is a simple script that uses ssh-agents and powershell to aggregate simple information about linux-hosted Apache Tomcat instances.  You'll need SSH and, preferably, an [ssh-agent](https://www.ssh.com/ssh/agent) running, with your keys `ssh-add`ed to it.

Basic Usage:
```Powershell
PS1> .\CheckTomcat.ps1 tom@myhost1.com,tom@myhost2.com
HOST            CATALINA_BASE       STATE RSS   VSZ    CPU LOGSZ
----            -------------       ----- ---   ---    --- -----
tom@myhost1.com /home/tom/catalina1 UP    95MiB 2.4GiB 0.0 120K 
tom@myhost1.com /tmp/mycatalina1    DOWN  ?     ?      ?   4.0K 
tom@myhost2.com /home/tom/catalina1 UP    95MiB 2.4GiB 0.0 120K 
```


## Using SSH Agents
Make sure an ssh agent is running.  In windows that's probably something like this:
```PowerShell
PS1> Get-Service ssh-agent
```

On my macbook, I usually wind up having an ssh agent running via `eval $(ssh-agent -s)`, *then* I launch `pwsh`. 

Add ssh keys as necessary.  
```
ssh-add path/to/id_rsa
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

## Help
```
NAME
    Get-TomcatStats

SYNOPSIS
    Returns information about tomcat instances on remote SSH hosts.


SYNTAX
    Get-TomcatStats [-SshHosts] <String[]> [<CommonParameters>]


DESCRIPTION
    Returns a combined list of status objects.  Each object will have the following members:

    HOST
    CATALINA_BASE
    STATE <UP|DOWN>
    RSS Resident State Size (allocated memory, excluding swap; human readable)
    VSZ Virtual Memory Size (total available)
    CPU pct usage at time of sample
    LOGSZ Total Size of $CATALINA_BASE/logs (human readable)
```
