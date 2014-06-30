##
## Quick & dirty KeePass file database backuper
##

#= Parameters
$scp= "c:\Apps\gow\bin\pscp.exe"
$puttySession= "<saved putty session name>"
$kpPath= "<path to>\KeePass_database.kdbx"
$hostDest= "<host>:~/<path>/"
$secret= "<path to encrypted pw file>.asc"

# Retriev shell password from encrypted file
$sshPw= gpg -d $secret 2> $null
#echo "Pwd: $sshPw"

# Generate temporary dest file name
$target= $hostDest + "$(Time-FileName).kdbx"
#echo "Target: $target"

# Send file via ssh to host location
& $scp -scp -load $puttySession -pw $sshPw "$kpPath" $target

# Immediately clear out host password
Clear-Variable sshPw
