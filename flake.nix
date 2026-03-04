{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
      ];

      perSystem = {
        pkgs,
        lib,
        system,
        ...
      }: let
        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "clippy"
          ];
          targets = ["wasm32-unknown-unknown"];
        };

        buildInputs =
          (with pkgs; [
            openssl
            pkg-config
          ])
          ++ lib.optionals pkgs.stdenv.isLinux (
            with pkgs; [
              glib
              gtk3
              libsoup_3
              webkitgtk_4_1
              xdotool
              libayatana-appindicator
              librsvg
            ]
          )
          ++ lib.optionals pkgs.stdenv.isDarwin (
            with pkgs.darwin.apple_sdk.frameworks; [
              SystemConfiguration
              IOKit
              Carbon
              WebKit
              Security
              Cocoa
            ]
          );
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [inputs.rust-overlay.overlays.default];
        };

        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          nativeBuildInputs = with pkgs; [
            rustToolchain
            dioxus-cli
            lld
            tailwindcss_4
            watchman
          ];

          shellHook = ''
            export RUST_SRC_PATH="${rustToolchain}/lib/rustlib/src/rust/library"
          '';
        };
      };
    };
}
