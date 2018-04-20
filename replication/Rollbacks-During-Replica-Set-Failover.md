# Rollbacks During Replica Set Failover

## overview

复制集主节点stepped down后，其他从节点还没有把该主节点的最新数据复制到从节点，选举完成后，之前发生故障的主节点再次被加入复制集，
此时为保障数据库一致性，之前发生故障的主节点会回滚掉没有写入到从节点的数据

## Collect Rollback Data

1. 回滚数据已bson文件形式存放在dbpath文件夹下的rollback目录下，命名格式如下：
    
    <database>.<collection>.<timestamp>.bson

2. 可以使用bsondump命令读取回滚文件


## Avoid Replica Set Rollbacks

1. 所有投票节点开启journal 并且使用 w: majority write concern 保证数据被写入大多节点

2. readConcern 为 local 或 available，可能会读到被回滚的数据或者没有被客户端确认的数据(数据还在没存，没有落盘)


## Rollback Limitation

1. 超过300M的数据无法回滚，如回滚数据超过300M, 日志中会出现如下日志：
    
    [replica set sync] replSet syncThread: 13410 replSet too much data to roll back

2. 如果出现回滚数据超过300M，可以直接保存数据或强制节点初始化同步（删除）