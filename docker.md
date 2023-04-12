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


## Nix

Make sure that the [Nix package manager](https://nix.dev/tutorials/install-nix) with [Nix flakes support enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes) is installed. ***Be sure to set yourself as a trusted user in the `nix.conf`; otherwise, build times will be very long.***

Nix provides the Marlowe tools and other tools used in the rest of these instructions:

- `cardano-cli`
- `marlowe-runtime-cli`
- `jq`
- `json2yaml`
- `curl`

Enter a Nix development shell that contains the Marlowe tools:

```console
$ git clone https://github.com/input-output-hk/marlowe-starter-kit/
$ cd marlowe-starter-kit
$ nix develop
```

This can also be done without cloning this repository:

```bash
nix develop github:input-output-hk/marlowe-starter-kit
```

These instructions were tested with Nix 2.15.0 under Debian 5.10.162.


## Docker

First, make sure that [docker-compose](https://docs.docker.com/compose/install/) is installed on your system. *These instructions will not work with Docker Desktop, but they do work with Docker and Docker Engine.* Also note that some installations of docker might use the command `docker compose` instead of `docker-compose`.

These instructions were tested with Docker version 20.10.5 and Docker Compose Version 1.25.0 under Debian 5.10.162.
### Network Selection

Select either the public Cardano testnet pre-production (`preprod`) or preview (`preview`). The `preprod` network is easiest to start with because it contains fewer transactions than `preview`, which makes synchronize the Cardano Node and the Marlowe Runtime indexers much faster.

```bash
export NETWORK=preprod
```


### Starting the Docker Containers

Now start the docker containers. Here we use `docker-compose`.


```bash
docker-compose up -d
```

```console
Creating network "marlowe-starter-kit_default" with the default driver
Creating marlowe-starter-kit_postgres_1      ... done
Creating marlowe-starter-kit_node_1          ... done
Creating marlowe-starter-kit_chain-indexer_1 ... done
Creating marlowe-starter-kit_chain-sync_1    ... done
Creating marlowe-starter-kit_tx_1            ... done
Creating marlowe-starter-kit_indexer_1       ... done
Creating marlowe-starter-kit_sync_1          ... done
Creating marlowe-starter-kit_proxy_1         ... done
Creating marlowe-starter-kit_web-server_1    ... done
```


## Check the Health of the Marlowe Runtime Services


### Docker

Check to make sure that all of the services were created and have the status "Up".

```bash
docker-compose ps
```

```console
               Name                              Command                 State               Ports         
-----------------------------------------------------------------------------------------------------------
marlowe-starter-kit_chain-indexer_1   /bin/entrypoint                 Up                                   
marlowe-starter-kit_chain-sync_1      /bin/entrypoint                 Up                                   
marlowe-starter-kit_indexer_1         /bin/entrypoint                 Up                                   
marlowe-starter-kit_node_1            entrypoint                      Up (healthy)                         
marlowe-starter-kit_postgres_1        docker-entrypoint.sh postgres   Up (healthy)   5432/tcp              
marlowe-starter-kit_proxy_1           /bin/entrypoint                 Up             0.0.0.0:3700->3700/tcp
marlowe-starter-kit_sync_1            /bin/entrypoint                 Up                                   
marlowe-starter-kit_tx_1              /bin/entrypoint                 Up                                   
marlowe-starter-kit_web-server_1      /bin/entrypoint                 Up             0.0.0.0:3780->3780/tcp
```

Use the command `docker-compose stop` to stop the services and the command `docker-compose start` to restart them. The command `docker-compose down` will stop the services and destroy the data folders the resources used by the services: unless external volumes were used when starting the services, the Cardano blockchain and Marlowe database will be removed.


### Node Socket

Docker typically does not open permissions to the volume containing the Cardano node socket. Use the following commands to set those permissions. Make sure you have the `jq` command installed on your system; otherwise, set `CARDANO_NODE_SOCKE_PATH` manually.

```bash
export CARDANO_NODE_SOCKET_PATH=$(docker volume inspect marlowe-starter-kit_shared | jq -r '.[0].Mountpoint')/node.socket

f=$(dirname $CARDANO_NODE_SOCKET_PATH)
while [[ $f != / ]]; do sudo chmod a+rx "$f"; f=$(dirname "$f"); done
sudo chmod a+rwx $CARDANO_NODE_SOCKET_PATH
```


### Environment Variables

Now set the environment variables for the Cardano and Marlowe Runtime services.


```bash
# Only required for `marlowe-cli` and `cardano-cli`.
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


### Marlowe Runtime Indexers

Check to see that `marlowe-chain-indexer` has reached the tip of the blockchain:

```bash
docker exec -it marlowe-starter-kit_postgres_1 psql -U postgres chain_preprod -c 'select max(slotno) from chain.block;'
```

```console
   max    
----------
 25633992
(1 row)
```

Also check to see that `marlowe-indexer` has *approximately* reached the tip of the blockchain:

```bash
docker exec -it marlowe-starter-kit_postgres_1 psql -U postgres chain_preprod -c 'select max(slotno) from marlowe.block;'
```

```console
   max    
----------
 25627611
(1 row)
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
