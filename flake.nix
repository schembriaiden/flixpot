{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustup
            pkg-config
            dioxus-cli

            # Desktop (WebKit/GTK)
            gtk3
            webkitgtk_4_1
            glib
            libsoup_3
            openssl
            cacert
          ];

          shellHook = ''
            rustup default stable
            rustup target add wasm32-unknown-unknown
          '';
        };
      });
}
