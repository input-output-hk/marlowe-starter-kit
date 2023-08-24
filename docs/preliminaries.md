# Preliminaries

This document introduces the recommended workflow options available to you for setting up the Marlowe Runtime to enable you to run the different lessons in this starter kit using Jupyter notebook. All these workflows facilitate the deployment of the [Marlowe Runtime services](https://docs.marlowe.iohk.io/docs/platform-and-architecture/architecture).

## Hosted deployment

The simplest and fastest method of deployment is to use the hosted deployment provided by [Demeter.run](https://demeter.run/). 

   * This method is not tied to any specific platform. 
   * The only system requirement is a browser. 

The [Demeter.run](https://demeter.run/) web3 development platform provides two extensions: 

   * Cardano Marlowe Runtime Extension
   * Cardano Node Extension

Together, these two extensions provide the Marlowe Runtime backend services and a Cardano node, so you don't need to set environment variables, install tools, run the full stack of backend services yourself locally, or wait for the Cardano node to sync. 

For details, please see the [Demeter run deployment document](demeter-run.md) for step-by-step guidance in setting up a new project with Demeter. 

Additionally, you can watch a [brief video walkthrough (2:32)](https://youtu.be/XnZ8gCjpl1E) of setting up a deployment with Demeter.

## Local deployment using Docker only

* Local version using full Docker

The local version using docker are described in [this document](./docker.md). The **full docker** flow runs both the runtime and the jupyter notebook in docker containers. 

## Local deployment using Docker plus Nix

* Local version using Docker + Nix

The **docker + nix** flow runs the runtime in docker and the jupyter notebook in a nix shell (only available for Linux).

