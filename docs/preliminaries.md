# Preliminaries

This document introduces three deployment approaches you can use for setting up [Marlowe Runtime services](https://docs.marlowe.iohk.io/docs/platform-and-architecture/architecture). 

Once you've selected and implemented the deployment approach that's best for your circumstances, the next step is to set up your keys and addresses to enable you to run the various lessons in this starter kit using Jupyter notebooks. 

# Three deployment approaches

The three deployment approaches are: 

1. Hosted deployment (OS independent, web-based)
2. Local deployment using Docker only (OS independent, Intel-based architecture, Windows, Linux or Mac)
3. Local deployment using a combination of Docker and Nix (Linux only)

**Note that ARM-based architecture is not supported at this time. This includes Apple M1 and M2 machines.** 

## Hosted deployment

The simplest and fastest deployment method is to use the hosted service provided by [Demeter.run](https://demeter.run/). 

   * This method is not tied to any specific platform 
   * The only system requirement is a browser 
   * It only takes a few minutes to get started 

The [Demeter.run](https://demeter.run/) web3 development platform provides a number of extensions. The following two extensions must be enabled for Marlowe Runtime services: 

   * Cardano Marlowe Runtime Extension
   * Cardano Node Extension

Together, these two extensions provide the Marlowe Runtime backend services and a Cardano node, so you don't need to set environment variables, install tools, run the full stack of backend services yourself locally, or wait for the Cardano node to sync. 

For details and step-by-step guideance, please see the [Demeter run deployment document](demeter-run.md). 

Additionally, you can watch a [brief video walkthrough (2:32)](https://youtu.be/XnZ8gCjpl1E) of the process.

## Local deployment using Docker only

You can deploy [Marlowe Runtime services](https://docs.marlowe.iohk.io/docs/platform-and-architecture/architecture), Jupyter notebooks and a Cardano node locally through Docker. This workflow runs everything in Docker containers. 

   * Requires Intel-based architecture
   * Requires local installation of Docker
   * Requires significant system resources on your local machine 
      * See [Recommended Resources for Deploying Marlowe Runtime](https://github.com/input-output-hk/marlowe-cardano/blob/main/marlowe-runtime/doc/resources.md)
   * May take several hours or more to initially sync the Cardano node
      * The time required to initially sync the Cardano node varies by a factor of ten, depending on the hardware environment you are using. The time required to sync on preview or preprod networks can be as little as 20 minutes up to several hours or more. The time required to initially sync on mainnet can vary from as little as 14 hours up to multiple days. 

For details, please see [Local deploys with Docker](./docker.md). 

## Local deployment using a combination of Docker and Nix

You can deploy [Marlowe Runtime services](https://docs.marlowe.iohk.io/docs/platform-and-architecture/architecture) and a Cardano node in Docker, combined with using a Nix shell to run the Jupyter notebooks from the HOST and set up all the required tools and environment variables. 

   * Requires Linux
   * Requires local installation of Docker
   * Requires Nix

For details, please see the section *Runtime deploy with Docker + Jupyter notebook with nix* in the document [Local deploys with Docker](./docker.md#runtime-deploy-with-docker--jupyter-notebook-with-nix). 

# Setting up keys and addresses

After you have completed your basic deployment, please see [this notebook](https://github.com/input-output-hk/marlowe-starter-kit/blob/main/setup/01-setup-keys.ipynb) for instructions on setting up signing keys and addresses. Once you've completed this step, you'll be ready to begin the lessons in this starter kit. 
