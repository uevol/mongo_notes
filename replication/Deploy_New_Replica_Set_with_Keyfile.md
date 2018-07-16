# Deploy New Replica Set with Keyfile Access Control

## 1. 创建数据库文件目录
```
mkdir -p /db/{conf,data,log}
```

## 2. 生成keyfile文件
```
openssl rand -base64 756 > /db/conf/keyfile
chmod 400 /db/conf/keyfile
```
生成后复制到所有节点

## 3. 编辑mongodb配置文件mongod.conf

```
storage:
  dbPath: "/db/data"
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
  path: "/db/log/mongod.log"
  logAppend: true
processManagement:
  fork: true
net:
  bindIp: 192.168.3.103,127.0.0.1
  port: 27017
security:
  keyFile: "/db/conf/keyfile"
replication:
  oplogSizeMB: 5000
  replSetName: "repl"
```

各mongod实例按实际情况修改以上参数

## 4. 启动mongod

```
mongod -f /db/conf/mongod.conf
```

## 5. 连接到复制集的一个节点

当前还没有用户被创建，只能通过localhost接口连接到 mongo shell，第一个用户被创建后，localhost接口关闭。

## 6. 初始化复制集

```
rs.initiate(
  {
    _id : "repl",
    members: [
      { _id : 0, host : "192.168.3.103:27017" },
      { _id : 1, host : "192.168.3.104:27017" },
      { _id : 2, host : "192.168.3.105:27017" }
    ]
  }
)
```

## 7. 创建管理员用户
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

## 8. 认证用户
在哪个数据库下创建的用户，必须到该数据库下认证用户
```
use admin
db.auth('admin', 'R00t@123')

或者

mongo -u "admin" -p "R00t@123" --authenticationDatabase "admin"
```

## 9. 创建集群管理员用户
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



