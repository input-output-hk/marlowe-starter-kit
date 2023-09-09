# Example of Using Marlowe Runtime with a CIP45 Wallet

This example shows how to use a [CIP-45](https://github.com/cardano-foundation/CIPs/pull/395) wallet such as [Eternl](https://input-output.atlassian.net/browse/PLT-7347) to sign Marlowe transactions. The example contract here simply receives a deposit and sends the funds to the Marlowe role-payout address for the benefit of a specified party. The funding policy ID and token name specify the native token to be sent; leave these blank to send ada.

A [video demonstration](https://youtu.be/3cR8tq0WE_8) is available.

The URL for Marlowe Runtime and the recipient's role token policy ID and asset name are specified as parameters to dapp's URL.

- `runtimeUrl=` the URL for the Marlowe Runtime instance.
- `recipientPolicy=` the policy ID for the recipient of the funds.
- `recipientName=` the asset name for the recipient of the funds.

On `mainnet`, for example, one can use an [Ada Handle](https://mint.handle.me/) (policy ID `f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a`) or an [Ada Domain](https://www.adadomains.io/) (policy ID `fc411f546d01e88a822200243769bbc1e1fbdde8fa0f6c5179934edb`) for the recipient. Note that for an Ada Handle do not include the `$` prefix in the asset name and for an Ada Domain do not include the `.ada` suffix in the asset name. The holder of the handle or domain can redeem the funds from the Marlowe payout address using their NFT using the [Marlowe Payouts](https://github.com/input-output-hk/marlowe-payouts) dapp.


## Source files

- [index.html](index.html): The HTML page for the application.
- [view.css](view.css): The CSS styling for the application
- [src/controller.js](src/controller.js): The JavaScript source code for the application.


## Running the application

- If you have Nix installed, simply execute [./run.sh](run.sh).
- Alternatively, if you have NodeJS installed, execute `npm install` and then `npx webpack-dev-server`.

The application is served from [http://127.0.0.1:3000](http://127.0.0.1:3000). It was tested with the [Eternl wallet](https://eternl.io/).

