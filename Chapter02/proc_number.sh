#!/bin/bash
proc_number=`PGOPTIONS='--statement_timeout=0' psql -AqXt -c"SELECT count(*) FROM pg_stat_activity"`
echo  $proc_number