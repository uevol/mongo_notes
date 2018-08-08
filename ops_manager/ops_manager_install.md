# ops manager安装手册(tar包安装)

## 1. 下载ops manager的tar包
```
https://downloads.mongodb.com/on-prem-mms/tar/mongodb-mms-3.6.5.47198.20180405T0844Z-1.x86_64.tar.gz
```

## 2. 解压tar包到待安装主机的合适路径
```
tar -zxf mongodb-mms-<version>.x86_64.tar.gz -C /path/to/ops_manager
```

## 3. 安装ops manager的后端数据库
```
ops manager本身作为一个web应用，需要一个mongodb应用数据库，生产环境下，以复制集的形式部署，提供高可用；如果要开启备份，还要部署一个备份数据库，生产环境，以复制集部署。

# 以mongod用户启动一个单实例复制集
sudo mkdir -p /data/appdb
sudo chown -R mongod:mongod /data/appdb

## 配置文件appdb.conf
storage:
  dbPath: "/data/appdb"
  engine: wiredTiger
  wiredTiger:
    engineConfig:
      cacheSizeGB: 1
  journal:
    enabled: true
systemLog:
  destination: file
  path: "/data/appdb/appdb.log"
  logAppend: true
processManagement:
  fork: true
net:
  port: 27017
replication:
  replSetName: "appdb"
  
## 启动mongo
mongod -f appdb.conf

## 初始化复制集
rs.initiate()

```

## 4. 修改ops manager的配置文件

    *. 启动一个三节点复制集作为应用数据库, 为了安全最好是3个数据节点

    *. On a server that is to run Ops Manager, open <install_directory>/conf/conf-mms.properties

    *. 修改mongo.mongoUri参数，参数中指定全部复制集成员，例如：

        mongo.mongoUri=mongodb://db1.example.com:40000,db2.example.com:40000,db3.example.com:40000

    *. 对一个开启认证的数据库，mongo.mongoUri必须包含认证信息，认证用户必须是以下角色：

        *. readWriteAnyDatabase
        *. dbAdminAnyDatabase.
        *. clusterAdmin if the database is a sharded cluster, otherwise clusterMonitor

        mongo.mongoUri=mongodb://mongodbuser1:password@mydb1.example.com:40000

## 4. 启动Ops Manager
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


## 5. 登录web页面并注册第一个用户
```
http://<OpsManagerHost>:8080
```

## 6. 备份gen.key数据

+ ops manger用gen.key文件加密应用于数据库之间的数据
+ 如果配置了多个ops manger应用（负载均衡），每个应用的服务器上必须有gen.key文件
+ gen.key的默认位置在${HOME}/.mongodb-mms/

