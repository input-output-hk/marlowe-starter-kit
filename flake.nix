{
  # TODO: Refactor to use std with grow pattern.
  #       e.g: https://github.com/divnix/std/blob/main/src/std/templates/rust/flake.nix
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
    std.url = "github:divnix/std";
    std.inputs.n2c.follows = "n2c";
    n2c.url = "github:nlewo/nix2container";
    std.inputs.devshell.url = "github:numtide/devshell";
  };

  outputs = { self, flake-compat, flake-utils, nixpkgs, jupyenv, marlowe, cardano-world, std, n2c }:
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
          p.postgresql
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
                  # TODO: See if these are still needed
                  pkgs.docker
                  pkgs.docker-compose
                ];
              };
            })
          ];
        });
        # NOTE: this was an attempt to make a first build of
        #       jupyter lab before packaging the docker image. It fails
        #       because there is no networking on nix build and `jupyter lab build`
        #       does an npm install.
        # TODO: Need to see if there is a workaround to make the first build persistent.
        #       or delete
        # marlowe-starter-kit-drv = pkgs.stdenv.mkDerivation {
        #   name = "marlowe-starter-kit";
        #   src = ./.;
        #   buildInputs = [jupyterlab pkgs.nodejs (extraPackages pkgs)];

        #   installPhase = ''
        #     mkdir $out
        #     cp -r $src/*.ipynb $out
        #     cp -r $src/images $out
        #     cp -r $src/mainnet $out
        #     cp -r $src/preprod $out
        #     cp -r $src/preview $out

        #     cd $out
        #     ${jupyterlab}/bin/jupyter-lab lab build
        #   '';
        # };

        operables = import ./nix/starter-env/operable.nix {
          inherit pkgs;
          inputs = {
            inherit jupyterlab;
            extraP = extraPackages pkgs;
            std = std.${system};
          };
        };
        devShellSTD = import ./nix/starter-env/devshell.nix {
          inputs = {
            inherit jupyterlab;
            inherit pkgs;
            mp = marlowe.packages.${system};
            cp = cardano-world.${system}.cardano.packages;
            extraP = extraPackages pkgs;
            std = std.${system};
          };
          cell = {};
        };
        oci-images = import ./nix/starter-env/oci-image.nix {
          inherit pkgs;
          inputs = {
            inherit jupyterlab;
            srcDir = ./.;
            std = std.${system};
            n2c = n2c.packages.${system};
            self = {
              inherit operables;
              devshell = devShellSTD;
            };
          };
        };

      in rec {
        packages = {
          inherit jupyterlab;
        };
        packages.default = jupyterlab;
        apps = {
          default = {
            program = "${jupyterlab}/bin/jupyter-lab";
            type = "app";
          };
          create-docker-images = {
            program = "${oci-images.all.copyToDockerDaemon}/bin/copy-to-docker-daemon";
            type = "app";
          };
        };
        devShell = devShellSTD.default;
        hydraJobs = {
          default = packages.default;
        };
      }
    );
}
