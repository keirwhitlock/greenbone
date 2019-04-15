# Greenbone Security Scanner


### Quick start

```bash
docker run --rm -d --name greenbone -p <hostport>:443 keirwhitlock/greenbone:latest
```

### Set administrator password on start

```bash
docker run --rm -d --name greenbone -e GREENBONE_ADMIN_PASSWORD=mysecretpassword -p <hostport>:443 keirwhitlock/greenbone:latest
```