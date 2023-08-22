{ inputs, cell}: {
  default = inputs.std.lib.dev.mkShell {
    packages = with inputs.pkgs; [
        nil
        json2yaml
        yaml2json
        gcc
        z3
        coreutils
        curl
        gnused
        jq
        gnugrep
        postgresql
        openssl
    ];
    nixago = [
    ];
    commands = [
        {
            name = "marlowe-cli";
            package = inputs.mp.marlowe-cli-exe-marlowe-cli-ghc8107;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "marlowe-finder";
            package = inputs.mp.marlowe-apps-exe-marlowe-finder-ghc8107;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "marlowe-runtime-cli";
            package = inputs.mp.marlowe-runtime-cli-exe-marlowe-runtime-cli-ghc8107;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "marlowe-pipe";
            package = inputs.mp.marlowe-apps-exe-marlowe-pipe-ghc8107;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "marlowe-scaling";
            package = inputs.mp.marlowe-apps-exe-marlowe-scaling-ghc8107;
            category = "1 - Marlowe + Cardano";
        }
        {
            name = "marlowe-oracle";
            package = inputs.mp.marlowe-apps-exe-marlowe-oracle-ghc8107;
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
