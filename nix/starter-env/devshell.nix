{ inputs, cell}: {
  default = inputs.std.lib.dev.mkShell {

    nixago = [
    ];
    commands = [
        {
            name = "marlowe-cli";
            package = inputs.mp.ghc8107-marlowe-cli-exe-marlowe-cli;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "marlowe-finder";
            package = inputs.mp.ghc8107-marlowe-apps-exe-marlowe-finder;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "marlowe-runtime-cli";
            package = inputs.mp.ghc8107-marlowe-runtime-cli-exe-marlowe-runtime-cli;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "marlowe-pipe";
            package = inputs.mp.ghc8107-marlowe-apps-exe-marlowe-pipe;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "marlowe-scaling";
            package = inputs.mp.ghc8107-marlowe-apps-exe-marlowe-scaling;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "marlowe-oracle";
            package = inputs.mp.ghc8107-marlowe-apps-exe-marlowe-oracle;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "cardano-address";
            package = inputs.cp.cardano-address;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "cardano-cli";
            package = inputs.cp.cardano-cli;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "cardano-wallet";
            package = inputs.cp.cardano-wallet;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "jupyter";
            help = "Jupyter notebook: https://docs.jupyter.org/en/latest/running.html";
            package = inputs.jupyterlab;
            category = "2 - starter kit";
        }
    ];
  };
}