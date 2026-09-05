This is a Linux masterclass...

# ETCD
/usr/local/bin
- etc etcdcctl

/etc/systemd/system
- etcd.service

/etc/etcd
- Stores etcd's config and TLS cert
- ca.crt kube-api-server.key kube-api-server.crt

/var/lib/etcd
- etcd data directory (the actual Key Value is stored)

/etc folder
- Stores system wide configuration files

/usr
- NOT USER
- UNIX SYSTEM RESOURCE ACTUALLY
- Stores bulk of installed software: binary, libraries, documentation and shared/ read-only data

/var (variable)
- Holds data that change frequently while system run

/systemd
- Stores unit file (text config file that tells systemd (a alw running daemon process) how to manage something)
- systemctl: command line tool to talk to systemd
- journalctl: command line to talk to journald (systemd's logging component)


# Kubernetes Control Plane
/usr/local/bin
- Stores the controller binaries
```
kube-apiserver \
    kube-controller-manager \
    kube-scheduler kubectl \
    /usr/local/bin/
```

kube-apiserver
```

  mkdir -p /var/lib/kubernetes/

  mv ca.crt ca.key \
    kube-api-server.key kube-api-server.crt \
    service-accounts.key service-accounts.crt \
    encryption-config.yaml \
    /var/lib/kubernetes/

```
Interesting
- api server has ca's private key stored
- it's own cert and key
- accounts key and cert (for the nodes)
- the encryption config

