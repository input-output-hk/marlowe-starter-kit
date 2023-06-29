{
  description = "Marlowe Starter Kit";

  nixConfig = {
    extra-substituters = [
      "https://cache.zw3rk.com"
      "https://cache.iog.io"
      "https://hydra.iohk.io"
      "https://tweag-jupyter.cachix.org"
    ];
    extra-trusted-public-keys = [
      "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "tweag-jupyter.cachix.org-1:UtNH4Zs6hVUFpFBTLaA4ejYavPo5EFFqgd7G7FxGW9g="
    ];
  };

  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "marlowe/iogx/nixpkgs";
    jupyenv.url = "github:tweag/jupyenv";
    marlowe = {
      type = "github";
      owner = "input-output-hk";
      repo = "marlowe-cardano";
      ref = "runtime@v0.0.2";
    };
    cardano-world.follows = "marlowe/cardano-world";
  };

  outputs = { self, flake-compat, flake-utils, nixpkgs, jupyenv, marlowe, cardano-world }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        mp = marlowe.packages.${system};
        cp = cardano-world.${system}.cardano.packages;
        extraPackages = p: [
          mp.ghc8107-marlowe-runtime-cli-exe-marlowe-runtime-cli
          mp.ghc8107-marlowe-cli-exe-marlowe-cli
          mp.ghc8107-marlowe-apps-exe-marlowe-finder
          mp.ghc8107-marlowe-apps-exe-marlowe-oracle
          mp.ghc8107-marlowe-apps-exe-marlowe-pipe
          mp.ghc8107-marlowe-apps-exe-marlowe-scaling
          cp.cardano-address
          cp.cardano-cli
          cp.cardano-wallet
          p.gcc
          p.z3
          p.coreutils
          p.curl
          p.gnused
          p.jq
          p.json2yaml
          p.yaml2json
        ];
        inherit (jupyenv.lib.${system}) mkJupyterlabNew;
        jupyterlab = mkJupyterlabNew ({...}: {
          nixpkgs = nixpkgs;
          imports = [
            ({pkgs, ...}: {
              kernel.bash.minimal = {
                enable = true;
                displayName = "Bash with Marlowe Tools";
                runtimePackages = extraPackages pkgs ++ [
                  pkgs.docker
                  pkgs.docker-compose
                ];
              };
            })
          ];
        });
      in rec {
        packages = {
          inherit jupyterlab;
          marlowe-runtime-cli = mp.ghc8107-marlowe-runtime-cli-exe-marlowe-runtime-cli;
          marlowe-cli = mp.ghc8107-marlowe-cli-exe-marlowe-cli;
          marlowe-pipe = mp.ghc8107-marlowe-apps-exe-marlowe-pipe;
        };
        packages.default = jupyterlab;
        apps = {
          default = {
            program = "${jupyterlab}/bin/jupyter-lab";
            type = "app";
          };
        };
        devShell = pkgs.mkShell {
          buildInputs = extraPackages pkgs;
        };
        hydraJobs = {
          default = packages.default;
        };
      }
    );
}
