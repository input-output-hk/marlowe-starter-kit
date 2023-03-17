{
  description = "Marlowe Starter Kit";

  nixConfig = {
    extra-substituters = [
      "https://cache.iog.io"
      "https://hydra.iohk.io"
      "https://tweag-jupyter.cachix.org"
    ];
    extra-trusted-public-keys = [
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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    jupyenv.url = "github:tweag/jupyenv";
    marlowe.url = "github:input-output-hk/marlowe-cardano/docker-20230313";
  };

  outputs = { self, flake-compat, flake-utils, nixpkgs, jupyenv, marlowe }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        mp = marlowe.packages.${system};
        extraPackages = p: [
          mp.marlowe-rt
          mp.marlowe-cli
          mp.marlowe.haskell.packages.marlowe-apps.components.exes.marlowe-finder
          mp.marlowe.haskell.packages.marlowe-apps.components.exes.marlowe-oracle
          mp.marlowe.haskell.packages.marlowe-apps.components.exes.marlowe-pipe
          mp.marlowe.haskell.packages.marlowe-apps.components.exes.marlowe-scaling
          mp.pkgs.cardano.packages.cardano-address
          mp.pkgs.cardano.packages.cardano-cli
          mp.pkgs.cardano.packages.cardano-wallet
          p.gcc
          p.z3
          p.git
          p.podman
          p.podman-compose
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
                runtimePackages = extraPackages pkgs;
              };
            })
          ];
        });
      in rec {
        packages = {
          inherit jupyterlab;
          marlowe = mp.marlowe-rt;
          marlowe-cli = mp.marlowe-cli;
          marlowe-pipe = mp.marlowe.haskell.packages.marlowe-apps.components.exes.marlowe-pipe;
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
