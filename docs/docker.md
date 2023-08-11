# Local deploys with Docker

This page provides instructions on setting up a local environment for running the Marlowe examples in this starter kit using Docker.

## Marlowe Runtime Architecture

The Marlowe Runtime consists of several backend services that works together with a web server.

![The architecture of Marlowe Runtime](images/runtime-architecture.png)


## Deploying Marlowe Runtime Locally Using Docker

First, make sure that docker and [docker-compose](https://docs.docker.com/compose/install/) are installed on your system.

> Note that some installations of docker might use the command `docker compose` instead of `docker-compose`.

These instructions were tested with:
- Docker version 20.10.5 and Docker Compose Version 1.25.0 under Debian 5.10.162.
- Docker desktop 4.20.1 on a Mac Ventura.

### Network Selection

Select either the public Cardano testnet pre-production (`preprod`) or preview (`preview`). The `preprod` network is easiest to start with because it contains fewer transactions than `preview`, which makes synchronize the Cardano Node and the Marlowe Runtime indexers much faster.

```console
$ export NETWORK=preprod
$ export CARDANO_TESTNET_MAGIC=1
# Or
$ export NETWORK=preview
$ export CARDANO_TESTNET_MAGIC=2
# Or
$ export NETWORK=mainnet
```

> Note that mainnet doesn't require a `CARDANO_TESTNET_MAGIC` environment variable.

### Starting the Docker Containers

Now start the docker containers. Here we use `docker-compose`.


```console
$ git clone https://github.com/input-output-hk/marlowe-starter-kit/
$ cd marlowe-starter-kit
$ docker-compose up -d
```

```console
Creating network "marlowe-starter-kit_default" with the default driver
Creating marlowe-starter-kit-postgres-1      ... done
Creating marlowe-starter-kit-node-1          ... done
Creating marlowe-starter-kit-chain-indexer-1 ... done
Creating marlowe-starter-kit-chain-sync-1    ... done
Creating marlowe-starter-kit-tx-1            ... done
Creating marlowe-starter-kit-indexer-1       ... done
Creating marlowe-starter-kit-sync-1          ... done
Creating marlowe-starter-kit-proxy-1         ... done
Creating marlowe-starter-kit-web-server-1    ... done
Creating marlowe-starter-kit-notebook-1      ... done
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
marlowe-starter-kit-chain-indexer-1   /bin/entrypoint                 Up
marlowe-starter-kit-chain-sync-1      /bin/entrypoint                 Up
marlowe-starter-kit-contract-1        /bin/entrypoint                 Up
marlowe-starter-kit-indexer-1         /bin/entrypoint                 Up
marlowe-starter-kit-node-1            entrypoint                      Up (healthy)
marlowe-starter-kit-notebook-1        /bin/entrypoint                 Up             0.0.0.0:8080->8080/tcp
marlowe-starter-kit-postgres-1        docker-entrypoint.sh postgres   Up (healthy)   5432/tcp
marlowe-starter-kit-proxy-1           /bin/entrypoint                 Up             0.0.0.0:3700->3700/tcp
marlowe-starter-kit-sync-1            /bin/entrypoint                 Up
marlowe-starter-kit-tx-1              /bin/entrypoint                 Up
marlowe-starter-kit-web-server-1      /bin/entrypoint                 Up             0.0.0.0:3780->3780/tcp
```

Use the command `docker-compose stop` to stop the services and the command `docker-compose start` to restart them. The command `docker-compose down` will stop the services and destroy the data folders the resources used by the services: unless external volumes were used when starting the services, the Cardano blockchain and Marlowe database will be removed.


### Jupyter notebook

Our entrypoint for the starter kit is a container that has a Jupyter notebook server with all the proper tools and environment variables set up. The first time it runs it might take a while to initialize, make sure the logs reach to this point

```bash
$ docker logs marlowe-starter-kit-notebook-1
```

```console
[2023-08-09 21:58:06 jupyenv] needs to build JupyterLab.
[LabBuildApp] JupyterLab 3.6.1
[LabBuildApp] Building in /nix/store/xylb0fivhrh8m91mngmf7ir0629ydd2l-oci-setup-setupNotebook/notebook/.jupyter/lab/share/jupyter/lab
[LabBuildApp] Building jupyterlab assets (production, minimized)
[I 22:00:36.356 NotebookApp] Writing notebook server cookie secret to .jupyter/runtime/notebook_cookie_secret
[I 22:00:36.358 NotebookApp] Authentication of /metrics is OFF, since other authentication is disabled.
[W 22:00:37.285 NotebookApp] WARNING: The notebook server is listening on all IP addresses and not using encryption. This is not recommended.
[W 22:00:37.285 NotebookApp] WARNING: The notebook server is listening on all IP addresses and not using authentication. This is highly insecure and not recommended.
[W 22:00:37.909 NotebookApp] Loading JupyterLab as a classic notebook (v6) extension.
[C 22:00:37.909 NotebookApp] You must use Jupyter Server v1 to load JupyterLab as notebook extension. You have v2.4.0 installed.
    You can fix this by executing:
        pip install -U "jupyter-server<2.0.0"
[I 22:00:37.914 NotebookApp] Serving notebooks from local directory: /nix/store/xylb0fivhrh8m91mngmf7ir0629ydd2l-oci-setup-setupNotebook/notebook
[I 22:00:37.914 NotebookApp] Jupyter Notebook 6.5.3 is running at:
[I 22:00:37.914 NotebookApp] http://a42a7f1fad4e:8080/
[I 22:00:37.914 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
```

> NOTE: You can follow the logs (instead of just printing) using `docker logs -f marlowe-starter-kit-notebook-1` and stop them with `Ctrl+C`.

Once you see the message `Jupyter Notebook 6.5.3 is running at:` you can access the notebooks through http://localhost:8080.

You can also enter the shell inside the docker container with the command

```bash
$ docker exec -it marlowe-starter-kit-notebook-1 sh
```

### Cardano Node

When `cardano-node` is started, it may take minutes or hours to synchronize with the tip of the blockchain, depending upon the network. Wait until querying the node shows that its `syncProgress` is 100%. Inside the `marlowe-starter-kit-notebook-1` shell execute the following command:

```bash
$ cardano-cli query tip --testnet-magic "$CARDANO_TESTNET_MAGIC" | json2yaml
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

Check to see that `marlowe-chain-indexer` has reached the tip of the blockchain. Inside the `marlowe-starter-kit-notebook-1` shell execute the following command:

```bash
$ psql chain_preprod -c 'select max(slotno) from chain.block;'
```

```console
   max
----------
 25633992
(1 row)
```

Also check to see that `marlowe-indexer` has *approximately* reached the tip of the blockchain.

```bash
$ psql chain_preprod -c 'select max(slotno) from marlowe.block;'
```

```console
   max
----------
 25627611
(1 row)
```

*Troubleshooting note:* If the `marlowe-chain-indexer` or `marlowe-indexer` query result is `null` or an extremely low number such as `-1`, you may need to reset the docker postgres volume. You can do that from the HOST machine:

```bash
docker compose stop postgres
docker compose remove postgres
docker volume rm marlowe-starter-kit_postgres
docker compose up -d
```


### Marlowe Runtime Proxy Service

Check that the `marlowe-runtime-cli` command can communicate with the Marlowe Runtime backend services by querying the history of one of the Marlowe contracts that has previously been executed on the blockchain.
From the `marlowe-starter-kit-notebook-1` shell you can execute the following command:

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

Check that one can communicate with the Marlowe Runtime web server and receive a `200 OK` response. From the `marlowe-starter-kit-notebook-1` shell you can execute the following command:


```bash
curl -sSI "$MARLOWE_RT_WEBSERVER_URL/healthcheck"
```

```console
HTTP/1.1 200 OK
Date: Thu, 16 Mar 2023 18:12:51 GMT
Server: Warp/3.3.24
Content-Type: application/json;charset=utf-8
```

## Connect from the host machine

Docker compose orchestrates the different services in the Marlowe Starter Kit as containers. The following services are accesible to the HOST through `localhost`.

| Service | Port |
| --- | --- |
| Marlowe Runtime Web Server | 3780 |
| Jupyter Notebook | 8080 |
| Marlowe Runtime Cli | 3700 |

A cardano node instance is also executed inside a container, and in order to use tools like `cardano-cli` from the HOST you need access to the node socket.

The following instructions only works on Linux, because Windows and Mac run the container inside a VM and file sockets can't be shared from the HOST to a VM.

You can use `nix` to access `jq`, `cardano-cli`, `marlowe-runtime-cli` and other tools without having to globally install them. Make sure that the [Nix package manager](https://nix.dev/tutorials/install-nix) with [Nix flakes support enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes) is installed. ***Be sure to set yourself as a trusted user in the `nix.conf`; otherwise, build times will be very long.***

```console
$ git clone https://github.com/input-output-hk/marlowe-starter-kit/
$ cd marlowe-starter-kit
$ nix develop
```

The following script will set the `CARDANO_NODE_SOCKET_PATH` environment variable and open the permissions to the socket.

```bash
export CARDANO_NODE_SOCKET_PATH=$(docker volume inspect marlowe-starter-kit_shared | jq -r '.[0].Mountpoint')/node.socket

f=$(dirname $CARDANO_NODE_SOCKET_PATH)
while [[ $f != / ]]; do sudo chmod a+rx "$f"; f=$(dirname "$f"); done
sudo chmod a+rwx $CARDANO_NODE_SOCKET_PATH
```

You can then use `cardano-cli` to query the node.


```console
$ cardano-cli query tip --testnet-magic "$CARDANO_TESTNET_MAGIC" | json2yaml
```

You can see other relevent environment variables in the [environment-variables.md](./environment-variables.md) document.