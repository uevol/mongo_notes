# ops manager install

## 1. Download the latest version of the Ops Manager archive
```
https://downloads.mongodb.com/on-prem-mms/tar/mongodb-mms-3.6.5.47198.20180405T0844Z-1.x86_64.tar.gz
```

## 2. Install the Ops Manager package on each server being used for Ops Manager
```
tar -zxf mongodb-mms-<version>.x86_64.tar.gz
```

## 3. Configure the Ops Manager connection to the Ops Manager Application Database

    *. 启动一个三节点复制集作为应用数据库, 为了安全最好是3个数据节点

    *. On a server that is to run Ops Manager, open <install_directory>/conf/conf-mms.properties

    *. 修改mongo.mongoUri参数，参数中指定全部复制集成员，例如：

        mongo.mongoUri=mongodb://db1.example.com:40000,db2.example.com:40000,db3.example.com:40000

    *. 对一个开启认证的数据库，mongo.mongoUri必须包含认证信息，认证用户必须是以下角色：

        *. readWriteAnyDatabase
        *. dbAdminAnyDatabase.
        *. clusterAdmin if the database is a sharded cluster, otherwise clusterMonitor

        mongo.mongoUri=mongodb://mongodbuser1:password@mydb1.example.com:40000

## 4. Start Ops Manager
```
<install_directory>/bin/mongodb-mms start

[root@localhost bin]# ./mongodb-mms start
Starting pre-flight checks
Successfully finished pre-flight checks

Migrate Ops Manager data
   Running migrations...                                   [  OK  ]
Start Ops Manager server
   Instance 0 starting........................             [  OK  ]
Starting pre-flight checks
Successfully finished pre-flight checks

Start Backup Daemon...                                     [  OK  ]
```


## 5. Open the Ops Manager home page and register the first user
