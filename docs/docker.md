# Local deploys with Docker

This page provides instructions on setting up a local environment for running the `lessons` in this starter kit using Docker. There are two recipies included in this page:
* Full deploy with Docker
* Runtime deploy with Docker + Jupyter notebook with nix (only for linux)

Both options include a Runtime deploy using docker. The difference is that the first also includes a Docker container with the Jupyter notebook and all the required tools, while the other expects you to have them installed in your PATH. The second option is only available for Linux as you can't access the node socket running inside a Docker container from a Windows or Mac host.

Make sure that docker and [docker-compose](https://docs.docker.com/compose/install/) are installed on your system.

> Note that some installations of docker might use the command `docker compose` instead of `docker-compose`.

These instructions were tested with:
- Docker version 20.10.5 and Docker Compose Version 1.25.0 under Debian 5.10.162.
- Docker desktop 4.20.1 on a Mac Ventura.

## Marlowe Runtime Architecture

The Marlowe Runtime consists of several backend services that works together with a web server.

![The architecture of Marlowe Runtime](../images/runtime-architecture.png)

## Get a copy of the starter kit

If you haven't done it yet, clone a local version of the starter kit

```console
$ git clone https://github.com/input-output-hk/marlowe-starter-kit/
$ cd marlowe-starter-kit
```

## Network Selection

Select either the public Cardano testnet pre-production (`preprod`) or preview (`preview`). The `preprod` network is easiest to start with because it contains fewer transactions than `preview`, which makes synchronize the Cardano Node and the Marlowe Runtime indexers much faster.

```console
$ export NETWORK=preprod
# Or
$ export NETWORK=preview
# Or
$ export NETWORK=mainnet
```

### Full deploy with Docker

The docker-compose file includes all the runtime services and a container with the jupyter notebooks and all the required tools.


Start the containers using:


```console
$ docker-compose up -d
```

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

Follow the steps in the [setup/00-local-environment](http://localhost:8080/notebooks/setup/00-local-environment.ipynb) notebook to check the health and sync progress of the runtime.


## Runtime deploy with Docker + Jupyter notebook with nix
If you want to run the jupyer notebooks from the HOST (currently only available in Linux) you can use the nix shell to get all the required tools and environment variables set up.

First make sure you have [nix](https://nixos.org/download.html) with [flakes](https://nixos.wiki/wiki/Flakes) configured and the [IOHK binary caches](https://github.com/input-output-hk/marlowe-cardano#iohk-binary-cache). Then enter the nix shell by executing

```console
$ nix develop
```

After all the tools are downloaded you'll se a greeting message with some of the tools listed.

Select the network and start the services without the notebook container

```console
$ export NETWORK=preprod
$ docker-compose up -d --scale notebook=0
```

After the services have started, you can execute the following inside the nix shell to configure the needed variables.


```console
$ source scripts/fill-variables-from-docker.sh
```

The script might complain about the node socket not being writable, if that happens follow the `chmod`` suggestions and try again.

After the variables are set up you can start the jupyter notebook server with

```console
$ jupyter notebook --ip='*' --NotebookApp.token="" --NotebookApp.password="" --port 8080 --no-browser
```

Follow the steps in the [setup/00-local-environment](http://localhost:8080/notebooks/setup/00-local-environment.ipynb) notebook to check the health and sync progress of the runtime.

Make sure that the kernel is ready before executing the commands.
