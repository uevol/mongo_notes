# Replica Set Member

## Overview

1. 复制集是一组mongod实例，提供高可用和数据冗余功能

2. 最小复制是3节点复制集：
    1. 1个主节点，2个数据从节点
    2. 1个主节点，1个从节点， 一个投票节点

3. 3.0+版本，一个复制集最多可以有50个节点，但是最多只能有7个投票节点

![replica set](../public/pics/replica-set-read-write-operations-primary.bakedsvg.svg)

## 主节点(Primary)

1. 主节点是复制集中唯一接受写操作的节点, 复制集中最多只有一个主节点

2. 复制集中所有数据节点都可读，默认从主节点读


## 从节点(Secondaries)

1. 从节点跟主节点拥有相同的数据

2. 从节点通过复制主节点的oplog然后在异步进程中重放oplog

3. 可以设置读偏好，从从节点读数据

4. 可以设置从节点，实现特殊目(隐藏节点、延迟节点等)

    1. priority 0 member

        1. 优先级为0的节点不能成为主节点，并且不能触发选举

    2. hidden member（hidden： true）

        1. 隐藏节点保存数据，但是设置读偏好在复制集里对客户端不可读

        2. 隐藏节点一定是priority 0 member，可以有投票权

        3. db.isMaster()不显示隐藏节点信息

    3. Delayed member

        1. 延迟节点的数据比其他节点的数据晚一定时间

        2. 延迟节点可用于快速恢复数据（延迟时间内发生误操作，比如误删库或误删集合，通过延迟节点恢复）

        3. 延迟节点一定是priority 0 member，同时应该是hidden 

        4. 延迟节点的延迟时间要小于oplog的窗口时间，同时要大于等于维护窗口时间

        5. 在分片集群不可用，因为分片集群的会在延迟时间没发生chunk移动


## 仲裁节点(Arbiter)

1. 仲裁节点不保存数据并且无法成为主节点，仅有投票权

2. 3.6版本，仲裁节点priority为0，低版本升级后后，mongodb自动设置priority为0

3. 仲裁节点要单独运行在一台机器

