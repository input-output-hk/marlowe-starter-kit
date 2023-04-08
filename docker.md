# Deploying Marlowe Runtime Locally Using Docker Compose

This notebook provides instructions on setting up one's environment for running the Marlowe examples in this starter kit. It covers the following information:

- Environment variables
- Deploying Marlowe Runtime

A [video of deploying Marlowe Runtime locally using docker compose](https://youtu.be/oRPTe5zbZBU) is available.


## Environment Variables

The various Marlowe tools use [environment variables](https://en.wikipedia.org/wiki/Environment_variable) to specify the values of parameters and the network locations of services. Only the enviornment variables for the particular tool(s) being used need be set; the others may be left unset or ignored. The following table summarizes the tools' use of these settings.

| Workflow            | Tool                  | Environment Variable        | Typical Value | Description                                                                                     |
|---------------------|-----------------------|-----------------------------|---------------|-------------------------------------------------------------------------------------------------|
| Marlowe CLI         | `marlowe-cli`         | `CARDANO_NODE_SOCKET_PATH`  | `node.socket` | Location of the socket for the `cardano-node` service.                                          |
|                     |                       | `CARDANO_TESTNET_MAGIC`     | 2             | The "magic number" for the Cardano testnet being used, or not set if `mainnet` is being used.   |
| Marlowe Runtime CLI | `marlowe-runtime-cli` | `MARLOWE_RT_HOST`           | `127.0.0.1`   | The host machine's IP address for Marlowe Runtime.                                              |
|                     |                       | `MARLOWE_RT_PORT`           | `3700`        | The port number for the `marlowe-proxy` service on the Marlowe Runtime host machine.            |
| Marlowe Runtime Web | `curl` etc.           | `MARLOWE_RT_WEBSERVER_HOST` | `127.0.0.1`   | The host machine's IP address for Marlowe Runtime's web server.                                 |
|                     |                       | `MARLOWE_RT_WEBSERVER_PORT` | `8080`        | The port number for the `marlowe-web-server` service on the Marlowe Runtime web server machine. |


## Deploying Marlowe Runtime

Marlowe Runtime consists of several backend services and work together with a web server.

![The architecture of Marlowe Runtime](images/runtime-architecture.png)


## Docker

First, make sure that either [docker-compose](https://docs.docker.com/compose/install/) or [podman-compose](https://github.com/containers/podman-compose#readme) is installed on your system.


### Git Submodule

This repository contains a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) that contains the docker-compose configuration for running a Cardano Node and Marlowe Runtime. Initialize this submodule.


```bash
git submodule update --init --recursive
```

```console
Submodule 'marlowe-compose' (git@github.com:bwbush/marlowe-compose.git) registered for path 'marlowe-compose'
Cloning into '/extra/iohk/marlowe-starter-kit/marlowe-compose'...
Submodule path 'marlowe-compose': checked out '19fe4263350212537f93e53b2297ca81772d8edc'
```


### Network Selection

Select either the public Cardano testnet pre-production (`preprod`) or preview (`preview`). The `preprod` network is easiest to start with because it contains fewer transactions than `preview`, which makes synchronize the Cardano Node and the Marlowe Runtime indexers much faster.

```bash
export NETWORK=preprod
```


### Starting the Docker Containers

Now start the docker containers. Here we use `podman-compose`, but the `docker-compose` works identically.


```bash
podman-compose -f marlowe-compose/compose.yaml up -d
```

```console
['podman', '--version', '']
using podman version: 4.3.1
** excluding:  set()
podman volume inspect marlowe-compose_shared || podman volume create marlowe-compose_shared
['podman', 'volume', 'inspect', 'marlowe-compose_shared']
['podman', 'volume', 'create', '--label', 'io.podman.compose.project=marlowe-compose', '--label', 'com.docker.compose.project=marlowe-compose', 'marlowe-compose_shared']
['podman', 'volume', 'inspect', 'marlowe-compose_shared']
podman volume inspect marlowe-compose_node-db || podman volume create marlowe-compose_node-db
['podman', 'volume', 'inspect', 'marlowe-compose_node-db']
['podman', 'volume', 'create', '--label', 'io.podman.compose.project=marlowe-compose', '--label', 'com.docker.compose.project=marlowe-compose', 'marlowe-compose_node-db']
['podman', 'volume', 'inspect', 'marlowe-compose_node-db']
['podman', 'network', 'exists', 'marlowe-compose_default']
podman run --name=marlowe-compose_node_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-compose --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-compose --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit/marlowe-compose --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=node -e NETWORK=preprod -v marlowe-compose_shared:/ipc -v marlowe-compose_node-db:/opt/cardano/data --net marlowe-compose_default --network-alias node --restart unless-stopped --healthcheck-command /bin/sh -c 'socat -u OPEN:/dev/null UNIX-CONNECT:/ipc/node.socket' --healthcheck-interval 10s --healthcheck-timeout 5s --healthcheck-retries 10 inputoutput/cardano-node:1.35.4
exit code: 0
podman volume inspect marlowe-compose_postgres || podman volume create marlowe-compose_postgres
['podman', 'volume', 'inspect', 'marlowe-compose_postgres']
['podman', 'volume', 'create', '--label', 'io.podman.compose.project=marlowe-compose', '--label', 'com.docker.compose.project=marlowe-compose', 'marlowe-compose_postgres']
['podman', 'volume', 'inspect', 'marlowe-compose_postgres']
['podman', 'network', 'exists', 'marlowe-compose_default']
podman run --name=marlowe-compose_postgres_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-compose --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-compose --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit/marlowe-compose --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=postgres -e POSTGRES_LOGGING=true -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e TZ=UTC -v marlowe-compose_postgres:/var/lib/postgresql/data -v /extra/iohk/marlowe-starter-kit/marlowe-compose/preprod/init.sql:/docker-entrypoint-initdb.d/init.sql --net marlowe-compose_default --network-alias postgres --log-driver=json-file --log-opt=max-file=10 --log-opt=max-size=200k --restart unless-stopped --healthcheck-command /bin/sh -c 'pg_isready -U postgres' --healthcheck-interval 10s --healthcheck-timeout 5s --healthcheck-retries 5 postgres:11.5-alpine
exit code: 0
podman volume inspect marlowe-compose_shared || podman volume create marlowe-compose_shared
['podman', 'volume', 'inspect', 'marlowe-compose_shared']
['podman', 'network', 'exists', 'marlowe-compose_default']
podman run --name=marlowe-compose_chain-indexer_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-compose --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-compose --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit/marlowe-compose --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=chain-indexer -e NODE_CONFIG=/node/config.json -e DB_NAME=chain_preprod -e DB_USER=postgres -e DB_PASS=postgres -e DB_HOST=postgres -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket -v marlowe-compose_shared:/ipc -v /extra/iohk/marlowe-starter-kit/marlowe-compose/preprod/node:/node --net marlowe-compose_default --network-alias chain-indexer -u 0:0 --restart unless-stopped iohkbuild/marlowe:chain-indexer-20230302
exit code: 0
podman volume inspect marlowe-compose_shared || podman volume create marlowe-compose_shared
['podman', 'volume', 'inspect', 'marlowe-compose_shared']
['podman', 'network', 'exists', 'marlowe-compose_default']
podman run --name=marlowe-compose_chain-sync_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-compose --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-compose --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit/marlowe-compose --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=chain-sync -e NODE_CONFIG=/node/config.json -e HOST=0.0.0.0 -e PORT=3715 -e QUERY_PORT=3716 -e JOB_PORT=3720 -e DB_NAME=chain_preprod -e DB_USER=postgres -e DB_PASS=postgres -e DB_HOST=postgres -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket -v marlowe-compose_shared:/ipc -v /extra/iohk/marlowe-starter-kit/marlowe-compose/preprod/node:/node --net marlowe-compose_default --network-alias chain-sync -u 0:0 --restart unless-stopped iohkbuild/marlowe:chain-sync-20230302
exit code: 0
['podman', 'network', 'exists', 'marlowe-compose_default']
podman run --name=marlowe-compose_indexer_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-compose --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-compose --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit/marlowe-compose --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=indexer -e DB_NAME=chain_preprod -e DB_USER=postgres -e DB_PASS=postgres -e DB_HOST=postgres -e MARLOWE_CHAIN_SYNC_HOST=chain-sync -e MARLOWE_CHAIN_SYNC_PORT=3715 -e MARLOWE_CHAIN_SYNC_QUERY_PORT=3716 -e MARLOWE_CHAIN_SYNC_COMMAND_PORT=3720 --net marlowe-compose_default --network-alias indexer --restart unless-stopped iohkbuild/marlowe:indexer-20230302
exit code: 0
['podman', 'network', 'exists', 'marlowe-compose_default']
podman run --name=marlowe-compose_tx_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-compose --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-compose --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit/marlowe-compose --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=tx -e HOST=0.0.0.0 -e PORT=3723 -e MARLOWE_CHAIN_SYNC_HOST=chain-sync -e MARLOWE_CHAIN_SYNC_PORT=3715 -e MARLOWE_CHAIN_SYNC_QUERY_PORT=3716 -e MARLOWE_CHAIN_SYNC_COMMAND_PORT=3720 --net marlowe-compose_default --network-alias tx --restart unless-stopped iohkbuild/marlowe:tx-20230302
exit code: 0
['podman', 'network', 'exists', 'marlowe-compose_default']
podman run --name=marlowe-compose_sync_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-compose --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-compose --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit/marlowe-compose --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=sync -e HOST=0.0.0.0 -e MARLOWE_SYNC_PORT=3724 -e MARLOWE_HEADER_SYNC_PORT=3725 -e MARLOWE_QUERY_PORT=3726 -e DB_NAME=chain_preprod -e DB_USER=postgres -e DB_PASS=postgres -e DB_HOST=postgres --net marlowe-compose_default --network-alias sync --restart unless-stopped iohkbuild/marlowe:sync-20230302
exit code: 0
['podman', 'network', 'exists', 'marlowe-compose_default']
2dcb895b7a2df47078339c727e8626a27d8fddc6705065cf7f0d18466d8c125d
599db9c3f59bf234057b1cdd179d9226249219c95e3319fa16687d5954189b98
podman run --name=marlowe-compose_proxy_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-compose --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-compose --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit/marlowe-compose --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=proxy -e HOST=0.0.0.0 -e PORT=3700 -e TX_HOST=tx -e TX_PORT=3723 -e SYNC_HOST=sync -e MARLOWE_SYNC_PORT=3724 -e MARLOWE_HEADER_SYNC_PORT=3725 -e MARLOWE_QUERY_PORT=3726 --net marlowe-compose_default --network-alias proxy -p 3700:3700 --restart unless-stopped iohkbuild/marlowe:proxy-20230302
exit code: 0
['podman', 'network', 'exists', 'marlowe-compose_default']
podman run --name=marlowe-compose_web-server_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-compose --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-compose --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit/marlowe-compose --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=web-server -e PORT=80 -e RUNTIME_HOST=proxy -e RUNTIME_PORT=3700 --net marlowe-compose_default --network-alias web-server -p 3780:80 --restart unless-stopped iohkbuild/marlowe:web-server-20230302
exit code: 0
```


## Check the Health of the Marlowe Runtime Services


### Docker

Check to make sure that all of the services were created and have the status "Up".

```bash
podman-compose -f marlowe-compose/compose.yaml ps
```

```console
['podman', '--version', '']
using podman version: 4.4.2
podman ps -a --filter label=io.podman.compose.project=marlowe-compose
CONTAINER ID  IMAGE                                               COMMAND     CREATED             STATUS                       PORTS                   NAMES
c9ea7fe655a3  docker.io/inputoutput/cardano-node:1.35.4                       About a minute ago  Up About a minute (healthy)                          marlowe-compose_node_1
0bf114667144  docker.io/library/postgres:11.5-alpine              postgres    About a minute ago  Up About a minute (healthy)                          marlowe-compose_postgres_1
41749da8a001  docker.io/iohkbuild/marlowe:chain-indexer-20230302              About a minute ago  Up About a minute                                    marlowe-compose_chain-indexer_1
ee9fd794fb8d  docker.io/iohkbuild/marlowe:chain-sync-20230302                 About a minute ago  Up About a minute                                    marlowe-compose_chain-sync_1
2fb140c547b6  docker.io/iohkbuild/marlowe:indexer-20230302                    About a minute ago  Up 56 seconds                                        marlowe-compose_indexer_1
a41802909143  docker.io/iohkbuild/marlowe:tx-20230302                         About a minute ago  Up 56 seconds                                        marlowe-compose_tx_1
c68488506a4d  docker.io/iohkbuild/marlowe:sync-20230302                       About a minute ago  Up About a minute                                    marlowe-compose_sync_1
2dcb895b7a2d  docker.io/iohkbuild/marlowe:proxy-20230302                      About a minute ago  Up About a minute            0.0.0.0:3700->3700/tcp  marlowe-compose_proxy_1
599db9c3f59b  docker.io/iohkbuild/marlowe:web-server-20230302                 About a minute ago  Up 59 seconds                0.0.0.0:3780->80/tcp    marlowe-compose_web-server_1
exit code: 0
```

Use the command `podman-compose -f marlowe-compose/compose.yaml stop` to stop the services and the command `podman-compose -f marlowe-compose/compose.yaml start` to restart them. The command `podman-compose -f marlowe-compose/compose.yaml down` will stop the services and destroy the data folders the resources used by the services: unless external volumes were used when starting the services, the Cardano blockchain and Marlowe database will be removed.


### Environment Variables

Now set the environment variables for the Cardano and Marlowe Runtime services.


```bash
if command -v podman > /dev/null
then
  DOCKER_CLI=podman
else
  DOCKER_CLI=docker
fi

# Only required for `marlowe-cli` and `cardano-cli`.
export CARDANO_NODE_SOCKET_PATH="$($DOCKER_CLI volume inspect marlowe-compose_shared | jq -r '.[0].Mountpoint')/node.socket"
case "$NETWORK" in
  preprod)
    export CARDANO_TESTNET_MAGIC=1
    ;;
  preview)
    export CARDANO_TESTNET_MAGIC=2
    ;;
  *)
    # Use `mainnet` as the default.
    unset CARDANO_TESTNET_MAGIC
    ;;
esac

# Only required for `marlowe-runtime-cli`.
export MARLOWE_RT_HOST="127.0.0.1"
export MARLOWE_RT_PORT=3700

# Only required for REST API.
export MARLOWE_RT_WEBSERVER_HOST="127.0.0.1"
export MARLOWE_RT_WEBSERVER_PORT=3780
export MARLOWE_RT_WEBSERVER_URL="http://$MARLOWE_RT_WEBSERVER_HOST:$MARLOWE_RT_WEBSERVER_PORT"
```


### Cardano Node

When `cardano-node` is started, it may take minutes or hours to synchronize with the tip of the blockchain, depending upon the network. Wait until querying the node shows that its `syncProgress` is 100%.

```bash
cardano-cli query tip --testnet-magic "$CARDANO_TESTNET_MAGIC" | json2yaml
```

```console
block: 731649
epoch: 57
era: Babbage
hash: ad9ed62386341677ada848804618b6198c1d4187a0bfbd008500d2ef9595943b
slot: 23307149
syncProgress: '100.00'
```


### Marlowe Runtime Proxy Service

Check that the `marlowe-runtime-cli` command can communicate with the Marlowe Runtime backend services by querying the history of one of the Marlowe contracts that has previously been executed on the blockchain.

```bash
marlowe-runtime-cli log "f06e4b760f2d9578c8088ea5289ba6276e68ae3cbaf5ad27bcfc77dc413890db#1"
```

```console
transaction f06e4b760f2d9578c8088ea5289ba6276e68ae3cbaf5ad27bcfc77dc413890db (creation)
ContractId:      f06e4b760f2d9578c8088ea5289ba6276e68ae3cbaf5ad27bcfc77dc413890db#1
SlotNo:          11630746
BlockNo:         224384
BlockId:         f729f57b3bd99dd1d55a5a65b8c74f459dadae784dd55536444770dd2c2cdd2e
ScriptAddress:   addr_test1wp4f8ywk4fg672xasahtk4t9k6w3aql943uxz5rt62d4dvqu3c6jv
Marlowe Version: 1



transaction 5a3ed57653b4635c76d2949558f3718e34324a8a1ffc740360ae7d85839de6d9 (close)
ContractId: f06e4b760f2d9578c8088ea5289ba6276e68ae3cbaf5ad27bcfc77dc413890db#1
SlotNo:     16674281
BlockNo:    458964
BlockId:    23adcef9d89afc4354155c62960512c810619d8244239f8c642745b034a58fc2
Inputs:     []
```    


### Marlowe Runtime Web Server

Check that one can communicate with the Marlowe Runtime web server and receive a `200 OK` response.


```bash
curl -sSI "$MARLOWE_RT_WEBSERVER_URL/healthcheck"
```

```console
HTTP/1.1 200 OK
Date: Thu, 16 Mar 2023 18:12:51 GMT
Server: Warp/3.3.24
Content-Type: application/json;charset=utf-8
```
