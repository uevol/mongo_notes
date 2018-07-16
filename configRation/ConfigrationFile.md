# Configration File

## File Format

MongoDB 2.6 introduced a YAML-based configuration file format.

The following sample configuration file contains several mongod settings that you may adapt to your local configuration:

```
systemLog:
   destination: file
   path: "/var/log/mongodb/mongod.log"
   logAppend: true
storage:
   journal:
      enabled: true
processManagement:
   fork: true
net:
   bindIp: 127.0.0.1
   port: 27017
setParameter:
   enableLocalhostAuthBypass: false
```

## Use the Configration File

```
mongod --config /etc/mongod.conf

mongos --config /etc/mongos.conf

```

Or

```
mongod -f /etc/mongod.conf

mongos -f /etc/mongos.conf

```

## Core Options

### systemLog Option

```
systemLog:
   destination: file
   path: "/var/log/mongodb/mongod.log"
   logAppend: true
```

### processManagement Option

```
processManagement:
   fork: true
```

### net Options

```
net:
   bindIp: 127.0.0.1
   port: 27017
```


### storage Options

```
storage:
   dbPath: <string>
   indexBuildRetry: <boolean>             # Default: True. Specifies whether mongod rebuilds incomplete indexes on the next start up.
   journal:
      enabled: <boolean>                  # Default: true on 64-bit systems, false on 32-bit systems                 
      commitIntervalMs: <num>             # Default: 100 or 30, The default journal commit interval is 100 milliseconds
   directoryPerDB: <boolean>              # Default: False
   syncPeriodSecs: <int>                  # Default: 60, The amount of time that can pass before MongoDB flushes data to the data files
   engine: <string>                       # Default: wiredTiger, Starting in MongoDB 3.2, wiredTiger is the default.
   mmapv1:
      preallocDataFiles: <boolean>
      nsSize: <int>
      quota:
         enforced: <boolean>
         maxFilesPerDB: <int>
      smallFiles: <boolean>
      journal:
         debugFlags: <int>
         commitIntervalMs: <num>
   wiredTiger:
      engineConfig:
         cacheSizeGB: <number>           # 50% of (RAM - 1 GB), or256 MB. range from 256MB to 10TB
         journalCompressor: <string>     # Default: snappy
         directoryForIndexes: <boolean>  # Default: false
      collectionConfig:
         blockCompressor: <string>       # Default: snappy     
      indexConfig:
         prefixCompression: <boolean>    # Default: true
   inMemory:
      engineConfig:
         inMemorySizeGB: <number>        # Default: 50% of physical RAM less 1 GB
```

### replication Option

```
replication:
   oplogSizeMB: <int>                    # For 64-bit systems, the oplog is typically 5% of available disk space.
   replSetName: <string>
   enableMajorityReadConcern: <boolean>  # Deprecated in 3.6
```

### sharding Options

```
sharding:
   clusterRole: <string>                # avalible values: configsrv(The instance starts on port 27019 by default), shardsrv(27018)
   archiveMovedChunks: <boolean>        # Starting in 3.2, MongoDB uses false as the default
```



































