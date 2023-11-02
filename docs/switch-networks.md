# Switch networks when using Docker Compose

When running Marlowe starter kit, there are three different networks to use alongside the `NETWORK` environment variable: preview, preprod, and mainnet. 

Stop the running containers with:

```
$ docker-compose down
```

Notice the containers are removed although the volumes are not removed. List the volumes by:

```
$ docker volume ls
```

This is generally desirable because it allows running the starter kit on the same network with significantly less sync time in the future.

However when switching networks without removing the volumes, the logs will show a network mismatch. The example below shows an attempt from switching between preprod to preview.

```
marlowe-starter-kit-node-1           | NetworkMagicMismatch "/data/db/protocolMagicId" (NetworkMagic {unNetworkMagic = 1}) (NetworkMagic {unNetworkMagic = 2})
```

Remove the associated volumes by passing the volume flag. If the container is still running, the force flag (`-f`) may be needed as well to remove the volume.

```
docker-compose down -v
```
