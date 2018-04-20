# Write Concern for Replica Sets

## Modify Default Write Concern

1. 默认只从主节点确认写操作，可以在每次写操作时修改默认设置

```
db.products.insert(
   { item: "envelopes", qty : 100, type: "Clasp" },
   { writeConcern: { w: 2, wtimeout: 5000 } }
)
```

2. Modify Default Write Concern For a Replica Set

For Example:

```
cfg = rs.conf()
cfg.settings.getLastErrorDefaults = { w: "majority", wtimeout: 5000 }
rs.reconfig(cfg)
```
