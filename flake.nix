{
  description = "flake for the rxRust project";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nmattia/naersk";
    mozillapkgs = {
      url = "github:cpcloud/nixpkgs-mozilla/install-docs-optional";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, mozillapkgs, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";
        mozilla = pkgs.callPackage (mozillapkgs + "/package-set.nix") {};
        rustChannel = (mozilla.rustChannelOf {
          rustToolchain = ./rust-toolchain;
          sha256 = "sjoPgMjnvXUI9HLeE5H0wbyV+Z8f1qvllXjHRmLckM4=";
          useDoc = false;
          # extensions = [ "rust-src" "rust-analyzer-preview" "clippy-preview" "rustfmt-preview" ];
        });
        naersk-lib = naersk.lib."${system}".override {
          cargo = rustChannel;
          rustc = rustChannel;
        };
      in
        {
          devShell = pkgs.mkShell {
            buildInputs = with rustChannel; [ rust pkgs.rustfmt ];
            # https://github.com/mozilla/nixpkgs-mozilla/issues/238
            RUST_SRC_PATH = "${rustChannel.rust-src}/lib/rustlib/src/rust/library";
          };
        }
    );
}
