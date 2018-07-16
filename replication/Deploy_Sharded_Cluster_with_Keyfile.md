# Deploy Sharded Cluster with Keyfile Access Control

## 1. 创建配置服务器复制集

### 1.1 创建数据库文件夹
```
mkdir -p /configdb/{conf,data,log}
```

### 1.2 生成keyfile文件
```
openssl rand -base64 756 > /db/conf/keyfile
chmod 400 /db/conf/keyfile
```
生成后复制到所有节点,集群中所有节点使用同一个keyfile

### 1.3 编辑配置文件
```
storage:
  dbPath: "/configdb/data"
  journal:
    enabled: true
systemLog:
  destination: file
  path: "/configdb/log/mongod.log"
  logAppend: true
processManagement:
  fork: true
net:
  bindIp: 192.168.3.103,127.0.0.1
  port: 27020
security:
  keyFile: "/configdb/conf/keyfile"
sharding:
  clusterRole: configsvr
replication:
  replSetName: "config"
```

### 1.4 启动mongod

```
mongod -f /configdb/conf/mongod.conf
```

### 1.5 连接到复制集的一个节点

当前还没有用户被创建，只能通过localhost接口连接到 mongo shell，第一个用户被创建后，localhost接口关闭。

## 6. 初始化复制集

```
rs.initiate(
  {
    _id: "config",
    configsvr: true,
    members: [
      { _id : 0, host : "192.168.3.103:27020" },
      { _id : 1, host : "192.168.3.104:27020" },
      { _id : 2, host : "192.168.3.105:27020" }
    ]
  }
)
```

## 2. 创建配置服务器复制集

### 2.1 创建数据库文件目录
```
mkdir -p /sharddb/{conf,data,log}
```

### 2.2 keyfile文件

集群中所有节点使用同一个keyfile, 使用上面的keyfile文件

### 2.3 编辑mongodb配置文件mongod.conf

```
storage:
  dbPath: "/sharddb/data"
  engine: wiredTiger
  wiredTiger:
    engineConfig:
      cacheSizeGB: 4
    indexConfig:
      prefixCompression: true
  journal:
    enabled: true
systemLog:
  destination: file
  path: "/sharddb/log/mongod.log"
  logAppend: true
processManagement:
  fork: true
net:
  bindIp: 192.168.3.103,127.0.0.1
  port: 27018
security:
  keyFile: "/sharddb/conf/keyfile"
replication:
  oplogSizeMB: 5000
  replSetName: "rs1"
sharding:
  clusterRole: shardsvr
```

各mongod实例按实际情况修改以上参数

### 2.4 启动mongod

```
mongod -f /sharddb/conf/mongod.conf
```

### 2.5 连接到复制集的一个节点

当前还没有用户被创建，只能通过localhost接口连接到 mongo shell，第一个用户被创建后，localhost接口关闭。

### 2.6 初始化复制集

```
rs.initiate(
  {
    _id : "rs1",
    members: [
      { _id : 0, host : "192.168.3.103:27018" },
      { _id : 1, host : "192.168.3.104:27018" },
      { _id : 2, host : "192.168.3.105:27018" }
    ]
  }
)
```

### 2.7 创建分片本地的用户管理员（可选操作）
1. 第一个用户创建完成后，localhost exception就不可用了，所以第一个用户（例如：userAdminAnyDatabase）必须具有创建用户的权限
2. 必须在主节点上创建用户

```
use admin
db.createUser(
  {
    user: "admin",
    pwd: "R00t@123",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
```
### 2.8 创建分片复制集本地集群管理员用户（可选操作）
集群管理员用户可以修改复制集配置
```
use admin
db.createUser(
	{
		user: 'cluster_admin',
		pwd: 'R00t@123',
		roles: [
			{role: 'clusterAdmin', db: 'admin'}
		]
	}
)
```

## 3. 创建mongos连接到集群

### 3.1 创建mongos文件夹
```
mkdir -p /mongos/{conf,data,log}
```

### 3.2 生成keyfile文件

集群中所有节点使用同一个keyfile, 使用上面的keyfile文件

### 3.3 编辑配置文件
```
systemLog:
  destination: file
  path: "/mongos/log/mongos.log"
  logAppend: true
processManagement:
  fork: true
net:
  bindIp: 192.168.3.103,127.0.0.1
  port: 27019
security:
  keyFile: "/mongos/conf/keyfile"
sharding:
  configDB: config/192.168.3.103:27020, 192.168.3.104:27020, 192.168.3.105:27020
```

### 3.4 启动mongod

```
mongos -f /mongos/conf/mongos.conf
```

### 3.5 连接到集群中一个mongos

当前还没有用户被创建，只能通过localhost接口连接到 mongo shell，第一个用户被创建后，localhost接口关闭。

### 3.6 在mongos上创建用户管理员
```
use admin
db.createUser(
  {
    user: "admin",
    pwd: "R00t@123",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
```

### 3.6 在mongos上创建集群管理员
```
use admin
db.createUser(
	{
		user: 'cluster_admin',
		pwd: 'R00t@123',
		roles: [
			{role: 'clusterAdmin', db: 'admin'}
		]
	}
)
```

## 4. 添加分片到集群

以下操作必须用集群管理员操作

### 4.1 添加分片
```
sh.addShard('rs1/192.168.3.103:27018')
```

### 4.2 为数据库开启分片
```
sh.enableSharding('test')
```

### 4.3 开启集合分片
```
sh.shardCollection("<database>.<collection>", { <key> : <direction> } )
```

片键必须是索引，如果集合是空的，会自动建索引












