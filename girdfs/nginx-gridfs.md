nginx-gridfs

## 安装nginx-gridfs

#### 1. 安装依赖包

```
yum -y install pcre-devel openssl-devel zlib-devel git gcc gcc-c++

git clone https://github.com/mdirolf/nginx-gridfs.git

cd nginx-gridfs/

git checkout v0.8

git branch

git submodule init

git submodule update
```

#### 2. 安装nginx

```
curl -O http://nginx.org/download/nginx-1.7.9.tar.gz
tar -zxvf nginx-1.7.9.tar.gz
cd nginx-1.7.9/
make -j8 && make install -j8


#如果报错
./configure --prefix=/usr/local/nginx   --with-openssl=/usr/include/openssl --add-module=/path/to/nginx-gridfs

#把第3行的-Werror错误去掉
vi objs/Makefile
make && make install


修改配置文件
vi /usr/local/nginx/conf/nginx.conf

#添加以下内容
 
        location /gridfstest/ {
            gridfs pics
            field=filename
            type=string;
            #user=test
            #pass=test;
            mongo 127.0.0.1:27017;
        }

#gridfstest：访问地址
#field=filename   http://192.168.3.240/girdfstest/filename
#type=string;     字符窜
#field=_id
#type=objectid;
#pics:数据库
#mongo 127.0.0.1:10001  #mongo的服务器地址及端口


#启动nginx
/usr/local/nginx/sbin/nginx
#配置修改后重新加载
/usr/local/nginx/sbin/nginx -s reload
```

#### 3. 使用mongofiles工具填充数据
```
mongofiles put 1.JPG -d pics -t jpg

2018-07-11T11:34:16.002+0800    connected to: localhost
added file: 1.JPG

mongofiles list -d pics

2018-07-11T11:34:33.037+0800    connected to: localhost
1.JPG   138424

mongofiles -d pics get 1.JPG

2018-07-11T13:39:50.775+0800 connected to: localhost
finished writing to 1.JPG
```

#### 4. http访问：
```
http://ipaddress:port/gridfstest/1.JPG
```

#### 5. 开启数据库认证后，认证失败

##### 1. 认证失败原因

mongodb在3.0版本之前默认使用的MongoDB Challenge and Response (MONGODB-CR)的认证机制，在3.0版本之后增加了Salted Challenge Response Authentication Mechanism (SCRAM)认证机制，并且是默认的认证机制。nginx-gridfs这个插件在github最后更新时间是5年前，当时使用的mongo-c-driver是0.7的版本，使用的是MONGODB-CR的认证机制，因为开发者5年前就不再维护这个仓库，mongo-c-driver的版本也没有更新，依然使用的是MONGODB-CR的认证机制，与现在默认使用的认证机制SCRAM不兼容，导致认证失败


##### 2. 解决方法

```
1. 删除当前的所有用户

	db.dropUser('username')

2. 关闭数据库，再以非认证的方式开启

3. 降级authSchema

	use admin

	db.system.version.update({ "_id" : "authSchema"}, {"$set": {"currentVersion" : 3 }}, {upsert: true})

	db.system.version.find({ "_id" : "authSchema"})

4. 关闭数据库以认证的方式开启数据库

5. 先创建用户管理员，在以用户管理员的角色创建其他用户






