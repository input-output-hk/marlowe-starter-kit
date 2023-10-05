# Starter Kit for Marlowe [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-green.svg)](https://github.com/input-output-hk/marlowe-starter-kit/issues/new)

<img align="right" src="images/marlowe-logo-symbol-purple.svg" width="20%"/>

Start learning how to build on Marlowe with minimal configuration. This repository contains a series of [Jupyter notebooks](https://jupyterlab.readthedocs.io/en/stable/) that will run through a progression of lessons in the browser.

You can ask questions about Marlowe in [the #ask-marlowe channel on the IOG Discord](https://discord.com/channels/826816523368005654/936295815926927390) or post problems with any lesson or notebook to [the issues list for the Marlowe Starter Kit github repository](https://github.com/input-output-hk/marlowe-starter-kit/issues).


## Quick Overview

If you've worked with Docker and containers before and want to run Marlowe services locally, follow the [Docker](docs/docker.md) instructions. Nix users can also use [Docker in their environment](./docs/docker.md#runtime-deploy-with-docker--jupyter-notebook-with-nix).

Otherwise, [demeter.run](docs/demeter-run.md) provides a free, limited-use hosted environment to run this starter kit entirely in the browser. This is *highly* recommended for newer users.

Each lesson contains a notebook with helper scripts to verify a working installation of required dependencies. The lessons gradually introduce new concepts about using Marlowe using smart contracts.

> While these examples are shown using testnet, please review how to [use Marlowe safely](docs/using-marlowe-safely.md) if running on mainnet.

## Contents

Lesson | Duration | Prerequsites | Video
:-- | :--: | :--: | :--:
[1 - Using Marlowe Runtime's CLI](lessons/01-runtime-cli/) | 30 mins | [Preliminaries](setup/00-local-environment.ipynb) | [video](https://youtu.be/pjDtuD5rimI)
[2 - Using Marlow Runtime's REST API](lessons/02-runtime-rest/) | 30 mins | [Preliminaries](setup/00-local-environment.ipynb) | [video](https://youtu.be/wgJVdkM2pBY)
[3 - Zero-Coupon Bond Using Marlowe's CLI](lessons/03-marlowe-cli/) | 20 mins | [Preliminaries](setup/00-local-environment.ipynb), [Lesson 1](lessons/01-runtime-cli/) | [video](https://youtu.be/ELc72BKf7ec)
[4 - Escrow Using Marlowe Runtime's REST API](lessons/04-escrow-rest/) | 35 mins | [Preliminaries](setup/00-local-environment.ipynb), [Lesson 2](lessons/02-runtime-rest/) | [video](https://youtu.be/E8m-PKbS9TI)
[5 - Swap of Ada for Djed using Marlowe Runtime's Rest API](lessons/05-swap-rest/) | 20 mins | [Preliminaries](setup/00-local-environment.ipynb), [Lesson 2](lessons/02-runtime-rest/) | [video](https://youtu.be/sSrVCRNoytU)
[6 - Simple web application using a CIP-30 wallet](lessons/06-cip30/) | 5 mins | [Preliminaries](setup/00-local-environment.ipynb), [Lesson 5](lessons/05-swap-rest/) | [video](https://youtu.be/EsILiHiNZWk)
[7 - Checking the safety of a Marlowe contract](lessons/07-safety/) | 10 mins | [Preliminaries](setup/00-local-environment.ipynb) |
[8 - Experimental web application using a CIP-45 wallet](lessons/08-cip45/) | 10 mins | [Preliminaries](setup/00-local-environment.ipynb) | [video](https://youtu.be/3cR8tq0WE_8)
[9 - Minting with Marlowe Tools](lessons/09-minting/) | 25 mins | [Preliminaries](setup/00-local-environment.ipynb) | [video](https://youtu.be/S0MOipqXpmQ)

## Under the Hood

### Marlowe Tools

Three alternative workflows are available for running Marlowe contracts:

1. Marlowe CLI (`marlowe-cli`) for lightweight experiments with Marlowe transactions.
2. Marlowe Runtime CLI (`marlowe-runtime-cli`) for non-web applications that use the Marlowe Runtime backend services.
3. Marlowe Runtime Web (`marlowe-web-server`) for web applications that use Marlowe Runtime backend services.

Marlowe Runtime provides a variety of transaction-building, UTxO management, querying, and submission services for using Marlowe contracts: this makes it easy to run Marlowe contracts without attending to the details of the Cardano ledger and Plutus smart contracts. On the contrary, Marlowe CLI does not support querying and UTxO management, so it is best suited for experienced Cardano developers.

![Tools for Running and Querying Marlowe Contracts](images/marlowe-tools.png)

### Marlowe Runtime

Marlowe Runtime consists of several backend services and work together with a web server. See the [Marlowe documentation](https://docs.marlowe.iohk.io/docs/developer-tools/runtime/marlowe-runtime) for more information on Marlowe Runtime.

![The architecture of Marlowe Runtime](images/runtime-architecture.png)


## Additional Resources

1. [Marlowe Documentation](https://marlowe.iohk.io/)
1. [Cardano's Extended UTxO Model](https://docs.cardano.org/learn/eutxo-explainer)
1. [Using Marlowe Safely](docs/using-marlowe-safely.md)
1. [Marlowe Playground](https://play.marlowe.iohk.io/#/)
1. [MarloweScan](https://marlowescan.com/)
1. [Marlowe within the Cardano ecosystem](https://developers.cardano.org/docs/smart-contracts/marlowe/)


## Licensing

You are free to copy, modify, and distribute Marlowe under the terms
of the Apache 2.0 license. See the link: [LICENSE](LICENSE) for details.
