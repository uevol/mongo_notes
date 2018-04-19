replica set data synchronization

# overview

1. intial sync，可以理解为全量同步
2. replication，追同步源的oplog，可以理解为增量同步


# initial sync

1. Secondary节点当出现如下状况时，需要先进行全量同步

    1. oplog为空
    2. local.replset.minvalid集合里_initialSyncFlag字段设置为true
    3. 内存标记initialSyncRequested设置为true
    
    这3个场景分别对应

    1. 新节点加入，无任何oplog，此时需先进性initial sync
    2. initial sync开始时，会主动将_initialSyncFlag字段设置为true，正常结束后再设置为false；如果节点重启时，发现_initialSyncFlag为true，说明上次全量同步中途失败了，此时应该重新进行initial sync
    3. 当用户发送resync命令时，initialSyncRequested会设置为true，此时会重新开始一次initial sync

2. intial sync流程

    1. 全量同步开始，设置minvalid集合的_initialSyncFlag
    2. 获取同步源上最新oplog时间戳为t1
    3. 全量同步除local数据库外的全部集合数据，（耗时）
    4. 获取同步源上最新oplog时间戳为t2
    5. 重放[t1, t2]范围内的所有oplog
    6. 获取同步源上最新oplog时间戳为t3
    7. 重放[t2, t3]范围内所有的oplog
    8. 建立集合所有索引 (3.4新特性，之前版本只创建_id indexes) （耗时）
    9. 获取同步源上最新oplog时间戳为t4
    10. 重放[t3, t4]范围内所有的oplog
    11. 全量同步结束，清除minvalid集合的_initialSyncFlag

# replication

initial sync结束后，接下来Secondary就会不断拉取主上新产生的oplog并重放。


# 注意事项
1. initial sync复制数据，效率较低，生产环境应该尽量避免initial sync出现，需合理配置oplog，按默认『5%的可用磁盘空间』来配置oplog在绝大部分场景下都能满足需求，特殊的case(case1, case2)可根据实际情况设置更大的oplog

2. 新加入节点时，可以通过物理复制的方式来避免initial sync，将Primary上的dbpath拷贝到新的节点，直接启动，这样效率更高

3. 当Secondary上需要的oplog在同步源上已经滚掉时，Secondary的同步将无法正常进行，会进入RECOVERING的状态，需向Secondary主动发送resyc命令重新同步。3.2版本目前有个bug，可能导致resync不能正常工作，必须强制(kill -9)重启节点，详情参考SERVER-24773

4. 生产环境，最好通过db.printSlaveReplicationInfo()来监控主备同步滞后的情况，当Secondary落后太多时，要及时调查清楚原因

5. 当Secondary同步滞后是因为主上并发写入太高导致，（db.serverStatus().metrics.repl.buffer.sizeBytes持续接近db.serverStatus().metrics.repl.buffer.maxSizeBytes），可通过调整Secondary上replWriter并发线程数来提升

6. 同步源根据ping time 和其他节点的状态自动切换

7. 3.2 版本 member with 1 vote 不能从members with 0 vote同步数据

8. If a secondary member has members[n].buildIndexes set to true, it can only sync from other members where buildIndexes is true. Members where buildIndexes is false can sync from any other member, barring other sync restrictions. buildIndexes is true by default


