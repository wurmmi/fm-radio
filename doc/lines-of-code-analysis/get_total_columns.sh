#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# File        : get_total_columns.sh
# Author      : Michael Wurm <wurm.michael95@gmail.com>
# Description : Custom output formatting of CLOC output.
#               See https://github.com/AlDanial/cloc/tree/v1.90#wrapping-cloc-in-other-scripts-
#-------------------------------------------------------------------------------

###
# NOTE: need to `sudo apt install sqlite3` to use this script.
###

SCRIPT_PATH=$(dirname $(readlink -f $0))
REPO_ROOT=$SCRIPT_PATH/../../
cd $REPO_ROOT

if test $# -eq 0 ; then
    echo "Usage: $0  [cloc arguments]"
    echo "       Run cloc to count lines of code with an additional"
    echo "       output column for total lines (code+comment+blank)."
    exit
fi
DBFILE=`tempfile`
cloc --sql 1 --sql-project x $@ | sqlite3 ${DBFILE}
SQL="select Language, count(File)   as files                       ,
                      sum(nBlank)   as blank                       ,
                      sum(nComment) as comment                     ,
                      sum(nCode)    as code                        ,
                      sum(nComment)+sum(nCode) as TotalWithoutBlank     ,
                      sum(nBlank)+sum(nComment)+sum(nCode) as Total
         from t group by Language order by code desc;
"

cd $SCRIPT_PATH
echo ${SQL} | sqlite3 -header ${DBFILE} | ./sqlite_formatter
rm ${DBFILE}
