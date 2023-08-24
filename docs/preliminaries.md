# Preliminaries

This document introduces three workflow options for setting up the [Marlowe Runtime services](https://docs.marlowe.iohk.io/docs/platform-and-architecture/architecture) to enable you to run the various lessons in this starter kit using Jupyter notebook. 

## 1. Hosted deployment

The simplest and fastest deployment method is to use the hosted service provided by [Demeter.run](https://demeter.run/). 

   * This method is not tied to any specific platform. 
   * The only system requirement is a browser. 
   * It only takes a few minutes to get started. 

The [Demeter.run](https://demeter.run/) web3 development platform provides two extensions: 

   * Cardano Marlowe Runtime Extension
   * Cardano Node Extension

Together, these two extensions provide the Marlowe Runtime backend services and a Cardano node, so you don't need to set environment variables, install tools, run the full stack of backend services yourself locally, or wait for the Cardano node to sync. 

For details, please see the [Demeter run deployment document](demeter-run.md) for step-by-step guidance in setting up a new project with Demeter. 

Additionally, you can watch a [brief video walkthrough (2:32)](https://youtu.be/XnZ8gCjpl1E) of setting up a deployment with Demeter.

## 2. Local deployment using Docker only

You can deploy [Marlowe Runtime services](https://docs.marlowe.iohk.io/docs/platform-and-architecture/architecture), Jupyter notebook and a Cardano node locally through Docker. This workflow runs everything in Docker containers. 

   * Requires Linux or Intel-based Mac.
   * Requires local installation of Docker
   * Requires significant system resources on your local machine.
   * May take several hours or more to initially sync the Cardano node.

For details, please see [Local deploys with Docker](./docker.md). 

## 3. Local deployment using a combination of Docker and Nix

You can deploy [Marlowe Runtime services](https://docs.marlowe.iohk.io/docs/platform-and-architecture/architecture) and a Cardano node in Docker. 

You can use a nix shell to run the Jupyter notebooks from the HOST and set up all the required tools and environment variables. 

   * Requires Linux
   * Requires local installation of Docker
   * Requires Nix

