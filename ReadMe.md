# Starter Kit for Marlowe + Wolfram Oracles

This repository contains lessons for testing Marlowe Oracles support through submitting `IChoice`.

Here's a reference PR for Marlowe-Wolfram Oracle integration:
https://github.com/input-output-hk/marlowe-cardano/pull/608


## Contents

- [Setup](#setup): two alternatives
    - Use [demeter.run](https://demeter.run/) extension for Marlowe Runtime: [using demeter.run's Marlowe Runtime extension (video) (2:32)](https://youtu.be/XnZ8gCjpl1E)
      -  Select the "Marlowe Tutorial" starter kit.
      -  Be sure to turn on the "Cardano Nodes" and "Cardano Marlowe Runtime" extensions.
      -  Check that those match the network you are using for the starter kit.
    - [Deploy Marlowe Runtime locally with docker](docker.md) and [launching Marlowe Runtime using Docker (video) (9:48)](https://youtu.be/45F5ld8NNHM).
- [Lessons](#lessons)
    - [0. Preliminaries](00-preliminaries.md) and [demonstration of setting up keys and addresses (video) (6:17)](https://youtu.be/hGBmj9ZrYHs)
    - [1. Simple Wolfram Oracle](11-wolfram.ipynb)
        
- [Additional Information](#additional-information)
    - [Overview of Marlowe Tools](#marlowe-tools)
    - [Overview of Marlowe Runtime](#marlowe-runtime)
    - [Using Marlowe Safely](#using-marlowe-safely)
    - [Manual installation using Nix](#manual-installation-using-nix)

You can ask questions about Marlowe in [the #ask-marlowe channel on the IOG Discord](https://discord.com/channels/826816523368005654/936295815926927390) or post problems with this lesson to [the issues list for the Marlowe Starter Kit github repository](https://github.com/input-output-hk/marlowe-starter-kit/issues).


---


## Setup

This repository is meant to be used with [demeter.run](https://demeter.run) to execute Marlowe contracts using Marlowe Runtime, or with another similar cloud deployment of Marlowe Runtime.
- [Using demeter.run's Marlowe Runtime extension (video) (2:42)](https://youtu.be/QeBGv2mvGnA) to access Marlowe Runtime.
-  Select the "Marlowe Tutorial" starter kit.
-  Be sure to turn on the "Cardano Nodes" and "Cardano Marlowe Runtime" extensions.
-  Check that those match the network you are using for the starter kit.

Alternatively, one can [deploy Marlowe Runtime locally with docker](docker.md).
- [Launching Marlowe Runtime using Docker (video) (9:48)](https://youtu.be/45F5ld8NNHM) to set up Marlowe Runtime.

If you are unfamiliar with the Marlowe smart-contract language or with the Cardano blockchain, you may want to familiarize yourself with the following information:

1. [The Marlowe Language](https://marlowe.iohk.io/)
2. [Cardano's Extended UTxO Model](https://docs.cardano.org/learn/eutxo-explainer).

## Additional Information


### Marlowe Tools

Three alternative workflows are available for running Marlowe contracts:

1. Marlowe CLI (`marlowe-cli`) for lightweight experiments with Marlowe transactions.
2. Marlowe Runtime CLI (`marlowe-runtime-cli`) for non-web applications that use the Marlowe Runtime backend services.
3. Marlowe Runtime Web (`marlowe-web-server`) for web applications that use Marlowe Runtime backend services.

Marlowe Runtime provides a variety of transaction-building, UTxO management, querying, and submission services for using Marlowe contracts: this makes it easy to run Marlowe contracts without attending to the details of the Cardano ledger and Plutus smart contracts. On the contrary, Marlowe CLI does not support querying and UTxO management, so it is best suited for experienced Cardano developers.

![Tools for Running and Querying Marlowe Contracts](images/marlowe-tools.png)


### Marlowe Runtime

Marlowe Runtime consists of several backend services and work together with a web server. See the [Marlowe documentation](https://github.com/input-output-hk/marlowe-doc/blob/main/README.md) for more information on Marlowe Runtime.

![The architecture of Marlowe Runtime](images/runtime-architecture.png)


### Using Marlowe Safely

If one plans to run a Marlowe contract on the Cardano `mainnet`, then one should check its safety before creating it, so that there is no chance of losing funds.

Here are the steps for checking the safety of a Marlowe contract:

1. Understand the [Marlowe Language](https://marlowe.iohk.io/).
2. Understand Cardano\'s [Extended UTxO Model](https://docs.cardano.org/learn/eutxo-explainer).
3. Read and understand the [Marlowe Best Practices Guide](https://github.com/input-output-hk/marlowe-cardano/blob/main/marlowe/best-practices.md).
4. Read and understand the [Marlowe Security Guide](https://github.com/input-output-hk/marlowe-cardano/blob/main/marlowe/security.md).
5. Use [Marlowe Playground](https://https://play.marlowe.iohk.io//) to flag warnings, perform static analysis, and simulate the contract.
6. Use [Marlowe CLI\'s](https://github.com/input-output-hk/marlowe-cardano/blob/main/marlowe-cli/ReadMe.md) `marlowe-cli run analyze` tool to study whether the contract can run on a Cardano network.
7. Run *all execution paths* of the contract on a [Cardano testnet](https://docs.cardano.org/cardano-testnet/overview).


### Manual Installation Using Nix

When using Marlowe tools within [demeter.run](http://demeter.run/), nothing needs to be installed.

If you are not using [demeter.run](http://demeter.run/) and have the [Nix package manager installed](https://nix.dev/tutorials/install-nix) with [Nix flakes support enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes), you can launch a Jupyter notebook server, open a development environment, or build the tools. ***Be sure to set yourself as a trusted user in the `nix.conf`; otherwise, build times will be very long.***

```

