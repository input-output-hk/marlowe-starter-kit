## Environment Variables

The various Marlowe tools use [environment variables](https://en.wikipedia.org/wiki/Environment_variable) to specify the values of parameters and the network locations of services. Only the enviornment variables for the particular tool(s) being used need be set; the others may be left unset or ignored. The following table summarizes the tools' use of these settings.

| Workflow            | Tool                  | Environment Variable        | Typical Value | Description                                                                                     |
| ------------------- | --------------------- | --------------------------- | ------------- | ----------------------------------------------------------------------------------------------- |
| Marlowe CLI         | `marlowe-cli`         | `CARDANO_NODE_SOCKET_PATH`  | `node.socket` | Location of the socket for the `cardano-node` service.                                          |
|                     |                       | `CARDANO_TESTNET_MAGIC`     | 2             | The "magic number" for the Cardano testnet being used, or not set if `mainnet` is being used.   |
| Marlowe Runtime CLI | `marlowe-runtime-cli` | `MARLOWE_RT_HOST`           | `127.0.0.1`   | The host machine's IP address for Marlowe Runtime.                                              |
|                     |                       | `MARLOWE_RT_PORT`           | `3700`        | The port number for the `marlowe-proxy` service on the Marlowe Runtime host machine.            |
| Marlowe Runtime Web | `curl` etc.           | `MARLOWE_RT_WEBSERVER_HOST` | `127.0.0.1`   | The host machine's IP address for Marlowe Runtime's web server.                                 |
|                     |                       | `MARLOWE_RT_WEBSERVER_PORT` | `8080`        | The port number for the `marlowe-web-server` service on the Marlowe Runtime web server machine. |
