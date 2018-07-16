# 分片集群迁移

configsvr

mongo/bin/mongod --dbpath /data/db/c --logpath /data/db/c/db.log  --logappend --fork --port 37017 --replSet conf --configsvr --bind_ip slave1




sh1

mongo/bin/mongod --dbpath /data/db/s1 --logpath /data/db/s1/db.log  --logappend --fork --port 47017 --replSet s1 --shardsvr --bind_ip slave1




sh2

mongo/bin/mongod --dbpath /data/db/s2 --logpath /data/db/s2/db.log  --logappend --fork --port 57017 --replSet s2 --shardsvr --bind_ip slave1



mongos

mongo/bin/mongos --configdb 'conf/slave1:37017' --logpath /data/db/mongos/db.log  --logappend --fork --port 27017


