{
  description = "Command-line client for a personal to-do and PR list";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.writers.writePython3Bin "personal" { doCheck = false; } (builtins.readFile ./bin/personal);

        devShells.default = pkgs.mkShell {
          packages = [ pkgs.python3 ];
          shellHook = ''
            export PATH="$PWD/bin:$PATH"
          '';
        };
      }
    );
}
