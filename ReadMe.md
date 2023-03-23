# Starter Kit for Marlowe

- [Lessons](#lessons)
    - [0. Preliminaries](00-preliminaries.md)
    - Zero-Coupon Bond (ZCB)
        - [1. ZCB using the Marlowe Runtime command-line client](01-runtime-cli.ipynb)
        - [2. ZCB using the Marlowe Runtime REST API](02-runtime-rest.ipynb)
        - [3. ZCB using the Marlowe command-line tool](03-marlowe-cli.ipynb)
    - [4. Escrow using Marlow Runtime REST API](04-escrow-rest.ipynb)
    - [5. Swap of Ada for Djed using Marlowe Runtime Rest API](05-swap-rest.ipynb)
- [Additional Information](#additional-information)
    - [Overview of Marlowe Tools](#marlowe-tools)
    - [Overview of Marlowe Runtime](#marlowe-runtime)
    - [Using Marlowe Safely](#using-marlowe-safely)
    - [Manual installation using Nix](#manual-installation-using-nix)

---


This repository is meant to be used with [demeter.run](https://demeter.run) to execute Marlowe contracts using Marlowe Runtime, or with a docker deployment of Marlowe Runtime. Alternatively, one can [deploy Marlowe Runtime locally with docker](docker.ipynb).

If you are unfamiliar with the Marlowe smart-contract language or with the Cardano blockchain, you may want to familiarize yourself with the following information:

1. [The Marlowe Language](https://marlowe-finance.io/)
2. [Cardano's Extended UTxO Model](https://docs.cardano.org/learn/eutxo-explainer).


## Lessons

- [Lesson 0. Preliminaries](00-preliminaries.md): This lesson describes how to create and fund the Cardano addresses used in the lessons in this starter kit.
- [Lesson 1. Marlowe Runtime's Command-Line Interface](01-runtime-cli.ipynb): This lesson shows how to use Marlowe Runtime to execute a zero-coupon bond contract using the command line for a Cardano testnet.
- [Lesson 2. Marlowe Runtime's REST Interface](02-runtime-rest.ipynb): This lesson shows how to use the REST API for Marlowe Runtime to execute a zero-coupon bond contract on a Cardano testnet.
- [Lesson 3. Marlowe CLI](03-marlowe-cli.ipynb): This lesson shows how to use the Marlowe CLI without Marlowe Runtime to execute a zero-coupon bond contract on a Cardano testnet.
- [Lesson 4. Escrow](04-escrow-rest.ipynb): This lesson shows how to use the REST API of Marlowe Runtime to execute an escrow contract on a Cardano testnet.
- [Lesson 5. Swap](05-swap-rest.ipynb): This lesson shows how to use the REST API of Marlowe Runtime to execute a swap contract for ada and djed on a Cardano testnet.


## Additional Information


### Marlowe Tools

Three alternative workflows are available for running Marlowe contracts:

1. Marlowe CLI (`marlowe-cli`) for lightweight experiments with Marlowe transactions.
2. Marlowe Runtime CLI (`marlowe`) for non-web applications that use the Marlowe Runtime backend services.
3. Marlowe Runtime Web (`marlowe-web-server`) for web applications that use Marlowe Runtime backend services.

Marlowe Runtime provides a variety of transaction-building, UTxO management, querying, and submission services for using Marlowe contracts: this makes it easy to run Marlowe contracts without attending to the details of the Cardano ledger and Plutus smart contracts. On the contrary, Marlowe CLI does not support querying and UTxO management, so it is best suited for experienced Cardano developers.

![Tools for Running and Querying Marlowe Contracts](images/marlowe-tools.png)


### Marlowe Runtime

Marlowe Runtime consists of several backend services and work together with a web server. See the [Marlowe documentation](https://github.com/input-output-hk/marlowe-doc/blob/main/README.md) for more information on Marlowe Runtime.

![The architecture of Marlowe Runtime](images/runtime-architecture.png)


### Using Marlowe Safely

If one plans to run a Marlowe contract on the Cardano `mainnet`, then one should check its safety before creating it, so that there is no chance of losing funds.

Here are the steps for checking the safety of a contract:

1. Understand the [Marlowe Language](https://marlowe-finance.io/).
2. Understand Cardano\'s [Extended UTxO Model](https://docs.cardano.org/learn/eutxo-explainer).
3. Read and understand the [Marlowe Best Practices Guide](https://github.com/input-output-hk/marlowe-cardano/blob/main/marlowe/best-practices.md).
4. Read and understand the [Marlowe Security Guide](https://github.com/input-output-hk/marlowe-cardano/blob/main/marlowe/security.md).
5. Use [Marlowe Playground](https://play.marlowe-finance.io/) to flag warnings, perform static analysis, and simulate the contract.
6. Use [Marlowe CLI\'s](https://github.com/input-output-hk/marlowe-cardano/blob/main/marlowe-cli/ReadMe.md) `marlowe-cli run analyze` tool to study whether the contract can run on a Cardano network.
7. Run *all execution paths* of the contract on a [Cardano testnet](https://docs.cardano.org/cardano-testnet/overview).


### Manual Installation Using Nix

When using Marlowe tools within [demeter.run](http://demeter.run/), nothing needs to be installed.

If you are not using [demeter.run](http://demeter.run/) and have the [Nix package manager installed](https://nix.dev/tutorials/install-nix) with [Nix flakes support enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes), you can launch a Jupyter notebook server, open a development environment, or build the tools.


#### Launching a Jupyter Server for Marlowe Tools

One can launch a Jupyter notebook server for the workbooks and tools as follows:

```console
$ git clone git@github.com:input-output-hk/marlowe-starter-kit/
$ cd marlowe-starter-kit
$ nix run
```

One can even run a Jupyter notebook server with Marlowe tools already installed (but no example notebooks) without manually cloning this repository:

```bash
nix run github:input-output-hk/marlowe-starter-kit
```


#### Opening a Development Shell

One can also enter a Nix development shell that contains the Marlowe tools:

```console
$ git clone git@github.com:input-output-hk/marlowe-starter-kit/
$ cd marlowe-starter-kit
$ nix develop
```

This can also be done without cloning this repository:

```bash
nix develop github:input-output-hk/marlowe-starter-kit
```


#### Building individual Tools

One can build individual Marlowe tools using Nix:

```bash
nix build github:input-output-hk/marlowe-starter-kit/#marlowe      -o build/marlowe
nix build github:input-output-hk/marlowe-starter-kit/#marlowe-cli  -o build/marlowe-cli
nix build github:input-output-hk/marlowe-starter-kit/#marlowe-pipe -o build/marlowe-pipe
```
