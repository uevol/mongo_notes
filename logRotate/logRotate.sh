#!/bin/bash

# @Author: wy
# @Date:   2018-07-11 17:25:11
# @Last Modified by:   wy
# @Last Modified time: 2018-07-12 11:35:36

set -u

set -e

# the config file contains all info about mongod or mongos instance on a host
LOG_PATH="logPath"

function kill_sigusr1 ()
{
    if [ $1 ]
    then
        DATETIME=`date "+%Y-%m-%d %H:%M:%S"`
        echo "kill -SIGUSR1 $1 @ $DATETIME" >> rotate_log.log
        kill -SIGUSR1 $1
    fi
}


function rotate_mongo ()
{
    MONGOS_PIDS=`/usr/sbin/pidof mongos`
    for pid in $MONGOS_PIDS;
    do
        kill_sigusr1 $pid
    done

    MONGOD_PIDS=`/usr/sbin/pidof mongod`
    for pid in $MONGOD_PIDS;
    do
        kill_sigusr1 $pid
    done

}


function tar_log ()
{
    LOG=`basename $1`
    LOG_DIR=`dirname $1`
    LOG_ROTATE=`find $LOG_DIR -name $LOG."$(date +%Y-%m-%d)*" ! -name "*.gz"`
    gzip $LOG_ROTATE
    DATETIME=`date "+%Y-%m-%d %H:%M:%S"`
    echo "tar $LOG_ROTATE @ $DATETIME" >> rotate_log.log
}


function rotate_log ()
{
    grep "^[^#]" $LOG_PATH | while read logFile
    do
        if [ $logFile ]
        then
            tar_log $logFile
        fi
    done
}


function main ()
{
    rotate_mongo
    rotate_log
}

main




