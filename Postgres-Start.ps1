# Starting or stoping Postgres server

$PG_Root = "C:\Apps\pgsql"
$CMD = "$PG_Root\bin\pg_ctl"
$PG_Data = "$PG_Root\data"

$oper = 'start'

# Find out whether server is running
$postgres = ps | ?{ $_.ProcessName -eq 'postgres' }
if ($postgres -and ($postgres.Count -gt 0)) {
	$oper = 'stop'
}

if (($oper -eq 'stop') -and (Ask-YesOrNo -message "Do you really want shout down database server")) {
	echo "Stoping"
	&$CMD -D $PG_Data stop
} 
if ($oper -eq 'start') {
	echo "Starting"
	$logfilename = "$((date).ToString().Replace('-','').Replace(':','').Replace(' ','_')).log"
	Start-Process "$CMD" -argumentlist " -D $PG_Data -l $PG_Root\log\$logfilename start"
}