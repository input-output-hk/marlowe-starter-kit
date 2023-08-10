{ inputs, pkgs }:
let
  inherit (inputs) std extraP;
  inherit (std.lib.ops) mkOperable;
in
{
  marlowe-starter-kit = notebookDir: mkOperable
    {
      package = inputs.jupyterlab;
      runtimeScript = ''
        cd ${notebookDir}
        ${inputs.jupyterlab}/bin/jupyter notebook --allow-root --ip='*' --NotebookApp.token="" --NotebookApp.password="" --port 8080 --no-browser
      '';
      runtimeInputs = extraP ++ [
        pkgs.coreutils
        pkgs.nodejs
        pkgs.postgresql
      ];
    };
}