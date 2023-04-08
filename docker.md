# Deploying Marlowe Runtime Locally Using Docker Compose

This notebook provides instructions on setting up one's environment for running the Marlowe examples in this starter kit. It covers the following information:

- Environment variables
- Deploying Marlowe Runtime

A [video of deploying Marlowe Runtime locally using docker compose](https://youtu.be/wgSvPlWUrf8) is available.


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


### Network Selection

Select either the public Cardano testnet pre-production (`preprod`) or preview (`preview`). The `preprod` network is easiest to start with because it contains fewer transactions than `preview`, which makes synchronize the Cardano Node and the Marlowe Runtime indexers much faster.

```bash
export NETWORK=preprod
```


### Starting the Docker Containers

Now start the docker containers. Here we use `podman-compose`, but the `docker-compose` works identically.


```bash
podman-compose up -d
```

```console
['podman', '--version', '']
using podman version: 4.3.1
** excluding:  set()
podman volume inspect marlowe-starter-kit_shared || podman volume create marlowe-starter-kit_shared
['podman', 'volume', 'inspect', 'marlowe-starter-kit_shared']
Error: inspecting object: no such volume marlowe-starter-kit_shared
['podman', 'volume', 'create', '--label', 'io.podman.compose.project=marlowe-starter-kit', '--label', 'com.docker.compose.project=marlowe-starter-kit', 'marlowe-starter-kit_shared']
['podman', 'volume', 'inspect', 'marlowe-starter-kit_shared']
podman volume inspect marlowe-starter-kit_node-db || podman volume create marlowe-starter-kit_node-db
['podman', 'volume', 'inspect', 'marlowe-starter-kit_node-db']
Error: inspecting object: no such volume marlowe-starter-kit_node-db
['podman', 'volume', 'create', '--label', 'io.podman.compose.project=marlowe-starter-kit', '--label', 'com.docker.compose.project=marlowe-starter-kit', 'marlowe-starter-kit_node-db']
['podman', 'volume', 'inspect', 'marlowe-starter-kit_node-db']
['podman', 'network', 'exists', 'marlowe-starter-kit_default']
['podman', 'network', 'create', '--label', 'io.podman.compose.project=marlowe-starter-kit', '--label', 'com.docker.compose.project=marlowe-starter-kit', 'marlowe-starter-kit_default']
['podman', 'network', 'exists', 'marlowe-starter-kit_default']
podman run --name=marlowe-starter-kit_node_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-starter-kit --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-starter-kit --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=node -e NETWORK=preprod -v marlowe-starter-kit_shared:/ipc -v marlowe-starter-kit_node-db:/opt/cardano/data --net marlowe-starter-kit_default --network-alias node --restart unless-stopped --healthcheck-command /bin/sh -c 'socat -u OPEN:/dev/null UNIX-CONNECT:/ipc/node.socket' --healthcheck-interval 10s --healthcheck-timeout 5s --healthcheck-retries 10 inputoutput/cardano-node:1.35.4
ca35d3e70d4a800a7498cc385b6c19e4e5f308983cba4297714a5c2b8b8a09fa
exit code: 0
podman volume inspect marlowe-starter-kit_postgres || podman volume create marlowe-starter-kit_postgres
['podman', 'volume', 'inspect', 'marlowe-starter-kit_postgres']
Error: inspecting object: no such volume marlowe-starter-kit_postgres
['podman', 'volume', 'create', '--label', 'io.podman.compose.project=marlowe-starter-kit', '--label', 'com.docker.compose.project=marlowe-starter-kit', 'marlowe-starter-kit_postgres']
['podman', 'volume', 'inspect', 'marlowe-starter-kit_postgres']
['podman', 'network', 'exists', 'marlowe-starter-kit_default']
podman run --name=marlowe-starter-kit_postgres_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-starter-kit --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-starter-kit --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=postgres -e POSTGRES_LOGGING=true -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e TZ=UTC -v marlowe-starter-kit_postgres:/var/lib/postgresql/data -v /extra/iohk/marlowe-starter-kit/preprod/init.sql:/docker-entrypoint-initdb.d/init.sql --net marlowe-starter-kit_default --network-alias postgres --log-driver=json-file --log-opt=max-file=10 --log-opt=max-size=200k --restart unless-stopped --healthcheck-command /bin/sh -c 'pg_isready -U postgres' --healthcheck-interval 10s --healthcheck-timeout 5s --healthcheck-retries 5 postgres:11.5-alpine
Resolved "postgres" as an alias (/home/bbush/.cache/containers/short-name-aliases.conf)
Trying to pull docker.io/library/postgres:11.5-alpine...
Getting image source signatures
. . .
Writing manifest to image destination
Storing signatures
e689419d18c324ecc552eaee07479fdab48138676ff344f12f67cb1a34f116c0
exit code: 0
podman volume inspect marlowe-starter-kit_shared || podman volume create marlowe-starter-kit_shared
['podman', 'volume', 'inspect', 'marlowe-starter-kit_shared']
['podman', 'network', 'exists', 'marlowe-starter-kit_default']
podman run --name=marlowe-starter-kit_chain-indexer_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-starter-kit --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-starter-kit --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=chain-indexer -e NODE_CONFIG=/node/config.json -e DB_NAME=chain_preprod -e DB_USER=postgres -e DB_PASS=postgres -e DB_HOST=postgres -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket -e HTTP_PORT=3781 -v marlowe-starter-kit_shared:/ipc -v /extra/iohk/marlowe-starter-kit/preprod/node:/node --net marlowe-starter-kit_default --network-alias chain-indexer -u 0:0 --restart unless-stopped ghcr.io/input-output-hk/marlowe-chain-indexer:0.0.1
Trying to pull ghcr.io/input-output-hk/marlowe-chain-indexer:0.0.1...
Getting image source signatures
. . .
Writing manifest to image destination
Storing signatures
13062bbbd9f16227a7e47a531301d1849041643ca9c5782f6804ad190ead6355
exit code: 0
podman volume inspect marlowe-starter-kit_shared || podman volume create marlowe-starter-kit_shared
['podman', 'volume', 'inspect', 'marlowe-starter-kit_shared']
['podman', 'network', 'exists', 'marlowe-starter-kit_default']
podman run --name=marlowe-starter-kit_chain-sync_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-starter-kit --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-starter-kit --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=chain-sync -e NODE_CONFIG=/node/config.json -e HOST=0.0.0.0 -e PORT=3715 -e QUERY_PORT=3716 -e JOB_PORT=3720 -e DB_NAME=chain_preprod -e DB_USER=postgres -e DB_PASS=postgres -e DB_HOST=postgres -e CARDANO_NODE_SOCKET_PATH=/ipc/node.socket -e HTTP_PORT=3782 -v marlowe-starter-kit_shared:/ipc -v /extra/iohk/marlowe-starter-kit/preprod/node:/node --net marlowe-starter-kit_default --network-alias chain-sync -u 0:0 --restart unless-stopped ghcr.io/input-output-hk/marlowe-chain-sync:0.0.1
Trying to pull ghcr.io/input-output-hk/marlowe-chain-sync:0.0.1...
Getting image source signatures
. . .
Writing manifest to image destination
Storing signatures
81fedafa708b190976801a4ba72cba8ddbeaa405c22ce88e4f1d7821ac53423f
exit code: 0
['podman', 'network', 'exists', 'marlowe-starter-kit_default']
podman run --name=marlowe-starter-kit_indexer_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-starter-kit --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-starter-kit --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=indexer -e DB_NAME=chain_preprod -e DB_USER=postgres -e DB_PASS=postgres -e DB_HOST=postgres -e MARLOWE_CHAIN_SYNC_HOST=chain-sync -e MARLOWE_CHAIN_SYNC_PORT=3715 -e MARLOWE_CHAIN_SYNC_QUERY_PORT=3716 -e MARLOWE_CHAIN_SYNC_COMMAND_PORT=3720 -e HTTP_PORT=3783 --net marlowe-starter-kit_default --network-alias indexer --restart unless-stopped ghcr.io/input-output-hk/marlowe-indexer:0.0.1
Trying to pull ghcr.io/input-output-hk/marlowe-indexer:0.0.1...
Getting image source signatures
. . .
Writing manifest to image destination
Storing signatures
3252b24b636b6da71e3e3ba083175c5793c1131badc42f617f98c8b94ef513f3
exit code: 0
['podman', 'network', 'exists', 'marlowe-starter-kit_default']
podman run --name=marlowe-starter-kit_tx_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-starter-kit --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-starter-kit --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=tx -e HOST=0.0.0.0 -e PORT=3723 -e MARLOWE_CHAIN_SYNC_HOST=chain-sync -e MARLOWE_CHAIN_SYNC_PORT=3715 -e MARLOWE_CHAIN_SYNC_QUERY_PORT=3716 -e MARLOWE_CHAIN_SYNC_COMMAND_PORT=3720 -e HTTP_PORT=3785 --net marlowe-starter-kit_default --network-alias tx --restart unless-stopped ghcr.io/input-output-hk/marlowe-tx:0.0.1
Trying to pull ghcr.io/input-output-hk/marlowe-tx:0.0.1...
Getting image source signatures
. . .
Writing manifest to image destination
Storing signatures
f999efcc4c0af4bcb3796491b6d5dae9d0e8a7b6daa99f7081250c3e645c00d5
exit code: 0
['podman', 'network', 'exists', 'marlowe-starter-kit_default']
podman run --name=marlowe-starter-kit_sync_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-starter-kit --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-starter-kit --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=sync -e HOST=0.0.0.0 -e MARLOWE_SYNC_PORT=3724 -e MARLOWE_HEADER_SYNC_PORT=3725 -e MARLOWE_QUERY_PORT=3726 -e DB_NAME=chain_preprod -e DB_USER=postgres -e DB_PASS=postgres -e DB_HOST=postgres -e HTTP_PORT=3784 --net marlowe-starter-kit_default --network-alias sync --restart unless-stopped ghcr.io/input-output-hk/marlowe-sync:0.0.1
Trying to pull ghcr.io/input-output-hk/marlowe-sync:0.0.1...
Getting image source signatures
. . .
Writing manifest to image destination
Storing signatures
a60452f4fd45970b1365793e58a546c0227440690f836806498b6164d0ae3f83
exit code: 0
['podman', 'network', 'exists', 'marlowe-starter-kit_default']
podman run --name=marlowe-starter-kit_proxy_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-starter-kit --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-starter-kit --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=proxy -e HOST=0.0.0.0 -e PORT=3700 -e TX_HOST=tx -e TX_PORT=3723 -e SYNC_HOST=sync -e MARLOWE_SYNC_PORT=3724 -e MARLOWE_HEADER_SYNC_PORT=3725 -e MARLOWE_QUERY_PORT=3726 -e HTTP_PORT=3786 --net marlowe-starter-kit_default --network-alias proxy -p 3700:3700 --restart unless-stopped ghcr.io/input-output-hk/marlowe-proxy:0.0.1
Trying to pull ghcr.io/input-output-hk/marlowe-proxy:0.0.1...
Getting image source signatures
. . .
Writing manifest to image destination
Storing signatures
346638b09663a201b03518748a28e3ecb68fa990be7b64846f77f8ae5f5eff61
exit code: 0
['podman', 'network', 'exists', 'marlowe-starter-kit_default']
podman run --name=marlowe-starter-kit_web-server_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=marlowe-starter-kit --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=marlowe-starter-kit --label com.docker.compose.project.working_dir=/extra/iohk/marlowe-starter-kit --label com.docker.compose.project.config_files=compose.yaml --label com.docker.compose.container-number=1 --label com.docker.compose.service=web-server -e PORT=3780 -e RUNTIME_HOST=proxy -e RUNTIME_PORT=3700 --net marlowe-starter-kit_default --network-alias web-server -p 3780:3780 --restart unless-stopped ghcr.io/input-output-hk/marlowe-web-server:0.0.1
Trying to pull ghcr.io/input-output-hk/marlowe-web-server:0.0.1...
Getting image source signatures
. . .
Writing manifest to image destination
Storing signatures
bcca22dc0b554290b525075056c9538c19bf186a5cca761a49f271840a018ffa
exit code: 0
```


## Check the Health of the Marlowe Runtime Services


### Docker

Check to make sure that all of the services were created and have the status "Up".

```bash
podman-compose ps
```

```console
['podman', '--version', '']
using podman version: 4.3.1
podman ps -a --filter label=io.podman.compose.project=marlowe-starter-kit
CONTAINER ID  IMAGE                                                COMMAND     CREATED        STATUS                      PORTS                   NAMES
ca35d3e70d4a  docker.io/inputoutput/cardano-node:1.35.4                        4 minutes ago  Up 4 minutes ago (healthy)                          marlowe-starter-kit_node_1
e689419d18c3  docker.io/library/postgres:11.5-alpine               postgres    4 minutes ago  Up 4 minutes ago (healthy)                          marlowe-starter-kit_postgres_1
13062bbbd9f1  ghcr.io/input-output-hk/marlowe-chain-indexer:0.0.1              4 minutes ago  Up 4 minutes ago                                    marlowe-starter-kit_chain-indexer_1
81fedafa708b  ghcr.io/input-output-hk/marlowe-chain-sync:0.0.1                 3 minutes ago  Up 3 minutes ago                                    marlowe-starter-kit_chain-sync_1
3252b24b636b  ghcr.io/input-output-hk/marlowe-indexer:0.0.1                    3 minutes ago  Up 3 minutes ago                                    marlowe-starter-kit_indexer_1
f999efcc4c0a  ghcr.io/input-output-hk/marlowe-tx:0.0.1                         3 minutes ago  Up 3 minutes ago                                    marlowe-starter-kit_tx_1
a60452f4fd45  ghcr.io/input-output-hk/marlowe-sync:0.0.1                       3 minutes ago  Up 3 minutes ago                                    marlowe-starter-kit_sync_1
346638b09663  ghcr.io/input-output-hk/marlowe-proxy:0.0.1                      3 minutes ago  Up 3 minutes ago            0.0.0.0:3700->3700/tcp  marlowe-starter-kit_proxy_1
bcca22dc0b55  ghcr.io/input-output-hk/marlowe-web-server:0.0.1                 3 minutes ago  Up 3 minutes ago            0.0.0.0:3780->3780/tcp  marlowe-starter-kit_web-server_1
exit code: 0
```

Use the command `podman-compose stop` to stop the services and the command `podman-compose start` to restart them. The command `podman-compose down` will stop the services and destroy the data folders the resources used by the services: unless external volumes were used when starting the services, the Cardano blockchain and Marlowe database will be removed.


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
export CARDANO_NODE_SOCKET_PATH="$($DOCKER_CLI volume inspect marlowe-starter-kit_shared | jq -r '.[0].Mountpoint')/node.socket"
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
