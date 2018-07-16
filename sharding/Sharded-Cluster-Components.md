# Sharded Cluster Components

## overview

1. 分片集群的组件：

    * shard: 3.6版本后，分片必须以复制集部署

    * mongos: 查询路由， 应用与分片集群的接口

    * config server: 配置服务器， 存储分片集群的元数据与配置设置。3.4后，必须以复制集配置

2. Number of Shards

分片设置至少需要2个分片节点

3. Number of mongos and Distribution

   * 一般一个应用配置一个mongos.

   * 一个应用配置一个mongos可以减少应用和路由之间的网络延迟

   * 配置多个mongo可以提供高可用


## Shards

1. Primary Shard

    * 每个数据库有一个主分片，用于存储未分片的集合

    * 主分片节点和复制集的主节点没有关联

    * 新建数据库时,mongos选择分片中数据量最少的节点作为主分片

    * movePrimary可以改变主分片，但是会发生数据迁移，影响集群的操作

2. Replica Set Config Servers¶

    * 配置服务器复制集

        * 不能有仲裁节点

        * 不能有延迟节点

        * 必须可以建索引

    * 配置服务器上的写操作的写关注是"majority", 用户要避免直接写配置数据库

    * 配置服务器上的读关注是"majority"


