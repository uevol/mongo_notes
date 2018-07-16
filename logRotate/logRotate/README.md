# MongoDB运行日志按天自动分割并压缩整理
自动分割MongoDB日志文件，就是指[Rotate MongoDB log files](https://docs.mongodb.com/manual/tutorial/rotate-log-files)，即让MongoDB每天（或每个星期，可自定义控制）生成一个日志文件，而不是将MongoDB所有的运行日志都放置在一个文件中，这样每个日志文件都相对较小，定位问题也更容易

## 1. 实现效果
在一台主机上，无论运行单个或多个mongod或mongos实例，通过定时运行脚本的方式，对每一个mongod或mongos实例的运行日志，按天自动切割，并压缩整理。

## 2. 实现方法
### 2.1 文件说明
+ logPath: 存放一台主机上运行的mongod或mongos实例的日志文件绝对路径，一行一个文件，用于定时脚本(logRotate.sh)解析, 示例内容如下：

```
# log files for mongod or mongos on a host                               
/home/mongod/data/shard01/rs1/mongod.log
/home/mongod/data/shard01/rs2/mongod.log
/home/mongod/data/shard01/rs3/mongod.log
/home/mongod/data/shard02/rs1/mongod.log
/home/mongod/data/shard02/rs2/mongod.log
/home/mongod/data/shard02/rs3/mongod.log
/home/mongod/data/configRepl/rs1/mongod.log
/home/mongod/data/mongos/mongos_27017.log
/home/mongod/data/mongos/mongos_27018.log
```
+ logRotate.sh: 通过crontab在每台主机定时运行，用于按天自动分割日志并压缩日志

### 2.2 实现步骤
以下步骤仅针对单台主机，如有多台主机，每台主机均需如下操作

#### 2.2.1 设置mongod或mongos日志参数logRotate
+ 如果要自动分割日志，logRotate的值必须是rename

+ 通过配置文件systemLog.logRotate配置项，或者命令行中 --logRotate参数可以指定 logRotate的具体行为：当systemLog.logRotate 或 --logRotate 被设置为rename时，logRotate重命名旧日志文件(在旧日志文件后追加时间戳)，并且在当前日志路径中新建一个与旧日志文件名相同的文件

+ logRotate的默认值就是rename，如果没有在配置文件或命令行中显示指定，该值就是rename

#### 2.2.2 分割日志并压缩
+ 分割和压缩日志部分，这里用脚本(logRotate.sh)来完成。需要将该文件夹(包含logPath、logRotate.sh，注意，logPath、logRotate.sh必须要在同一个文件夹内)上传到运行mongod或mongos的主机上任意合适位置

+ 上传完成后，必须修改logPath文件，文件内容是该主机上运行的mongod或mongos实例的日志文件绝对路径，一行一个文件

#### 2.2.3 设置定时任务(crontab)
在主机上设置定时任务，定时执行logRotate.sh脚本，方法如下：

```
# 执行命令
crontab -e 

# 添加以下内容，/path/to/logRotate.sh是脚本绝对路径，wq保存退出
55 23 * * *  /path/to/logRotate.sh 

# 执行命令查看定时任务是否添加成功
crontab -l
```
