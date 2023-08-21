# Preliminaries

This document introduces the recommended flows to setup the Marlowe Runtime and run the different lessons in jupyter notebook:

* Hosted version using [demeter.run](https://demeter.run/)
* Local version using full Docker
* Local version using Docker + Nix

All the flows facilitate the deployment of the [Marlowe Runtime services](https://docs.marlowe.iohk.io/docs/platform-and-architecture/architecture).

The [demeter.run](https://demeter.run/) web3 development platform provides an extension, *Cardano Marlowe Runtime*, that has Marlowe tools installed. This extension provides the Marlowe Runtime backend services and a Cardano node, so you don't need to set environment variables, install tools or run backend services. You can watch the [following video (2:32)](https://youtu.be/XnZ8gCjpl1E) to see how to create a project using Demeter.

The local version using docker are described in [this document](./docker.md). The **full docker** flow runs both the runtime and the jupyter notebook in docker containers. The **docker + nix** flow runs the runtime in docker and the jupyter notebook in a nix shell (only available for Linux).


