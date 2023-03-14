# Starter Kit for Marlowe Using Demeter.Run

This repository is meant to be used with [demeter.run](https://demeter.run) to execute Marlowe contracts using Marlowe Runtime, or with a docker deployment of Marlowe Runtime. See the [Marlowe documentation](https://github.com/input-output-hk/marlowe-doc/blob/main/README.md) for more information on Marlowe and Marlowe Runtime.

If you have the [Nix package manager installed](https://nix.dev/tutorials/install-nix) with [Nix flakes support enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes), you can launch a Jupyter notebook server for the workbooks and tools as follows:
```console
$ git clone git@github.com:input-output-hk/marlowe-starter-kit/
$ cd marlowe-starter-kit
$ nix run
```


## Marlowe Tools

Three alternative workflows are available for running Marlowe contracts:

1. Marlowe CLI (`marlowe-cli`) for lightweight experiments with Marlowe transactions.
2. Marlowe Runtime CLI (`marlowe`) for non-web applications that use the Marlowe Runtime backend services.
3. Marlowe Runtime Web (`marlowe-web-server`) for web applications that use Marlowe Runtime backend services.

Marlowe Runtime provides a variety of transaction-building, UTxO management, querying, and submission services for using Marlowe contracts: this makes it easy to run Marlowe contracts without attending to the details of the Cardano ledger and Plutus smart contracts. On the contrary, Marlowe CLI does not support querying and UTxO management, so it is best suited for experienced Cardano developers.

![Tools for Running and Querying Marlowe Contracts](images/marlowe-tools.png)


### Marlowe Runtime

Marlowe Runtime consists of several backend services and work together with a web server.

![The architecture of Marlowe Runtime](images/runtime-architecture.png)


## Lessons

- [Lesson 0. Preliminaries](00-preliminaries.ipynb): This lesson describes how to create and fund the Cardano addresses used in the lessons in this starter kit.
- [Lesson 1. Marlowe Runtime's Command-Line Interface](01-runtime-cli/ReadMe.ipynb): This lesson shows how to use Marlowe Runtime to execute a zero-coupon bond contract using the command line for a Cardano testnet.
- [Lesson 2. Marlowe Runtime's REST Interface](02-runtime-rest/ReadMe.ipynb): This lesson shows how to use the REST API for Marlowe Runtime to execute a zero-coupon bond contract on a Cardano testnet.
