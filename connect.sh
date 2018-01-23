#!/bin/bash

if [ -n "$CATTLE_SCRIPT_DEBUG" ]; then 
    set -x
fi

GIDDYUP=/opt/rancher/bin/giddyup

function add_root_user {
    if [ -n "$MONGO_INITDB_ROOT_USERNAME" ] && [ -n "$MONGO_INITDB_ROOT_PASSWORD" ]; then
        mongo admin --eval "printjson(db.createUser({user:\"$MONGO_INITDB_ROOT_USERNAME\", pwd: \"$MONGO_INITDB_ROOT_PASSWORD\", roles: [\"root\"]}))"
    fi
}

function cluster_init {
    sleep 10
    mongo --eval "printjson(rs.initiate())"
    for member in $($GIDDYUP service containers --exclude-self); do
        mongo --eval "printjson(rs.add('$member:27017'))"
        sleep 5
    done
}

function find_master {
    for member in $($GIDDYUP ip stringify --delimiter " "); do
        IS_MASTER=$(mongo --host $member --eval "printjson(db.isMaster())" | grep 'ismaster')
        if echo $IS_MASTER | grep "true"; then
            return 0
        fi
    done
    return 1
}
# Script starts here
# wait for mongo to start
$GIDDYUP service wait scale --timeout 120

# Wait until all services are up
sleep 10
find_master
if [ $? -eq 0 ]; then
    echo 'Master is already initated.. nothing to do!'
else
    echo 'Initiating the cluster!'
    cluster_init
    add_root_user
fi
