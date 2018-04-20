# replica set elections

## 选举触发条件
触发选举的条件有多种，例如

  -  向复制集添加新节点

  -  初始化复制集

  -  执行命令rs.stepDown()或rs.reconfig()

  -  从节点与主节点连接超时(默认配置是10s)

选举时无法进行写操作，可通多设置读偏好从从节点读取

## 影响选举的因素

  -  选举过程中无法进行写操作

  -  选举协议（3.2）： New replica sets, by default, use protocolVersion: 1

  -  复制集成员间心跳检测默认每2s一次，超时默认是10s.

  -  高优先级节点优先于低优先级节点发起选举，且更有可能胜出；低优先节级节点可能会短暂被选为主节点，但是复制集会持续发生选举，直到最高优先级节点被选为主节点

  -  复制集members[n].votes参数，参数值为0没有选举权，同时priority必须是0（3.2）；优先级大于0的成员必定有选举权

```
IMPORTANT

Do not alter the number of votes to control which members will become primary. Instead, modify the members[n].priority option. Only alter the number of votes in exceptional cases. For example, to permit more than seven members.
```