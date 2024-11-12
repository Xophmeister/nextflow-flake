{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.05;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    with flake-utils.lib; eachSystem allSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Nextflow 24.04.2 (fat binary)
        nextflow = pkgs.stdenv.mkDerivation {
          name = "nextflow";
          version = "23.04.2";

          src = pkgs.fetchurl {
            url = "https://github.com/nextflow-io/nextflow/releases/download/v${nextflow.version}/nextflow-${nextflow.version}-all";
            hash = "sha256-16bD6sxABkjahcClaGbOOdJAs6q0yI7kcBgPTc8YR7Q=";
          };

          nativeBuildInputs = [ pkgs.makeWrapper ];

          unpackPhase = "true";

          installPhase = ''
            mkdir -p $out/bin
            cp $src $out/nextflow
            chmod +x $out/nextflow

            makeWrapper $out/nextflow $out/bin/nextflow \
              --set JAVA_HOME ${pkgs.jdk11}
          '';
        };

        # NF-Test 0.9.2
        nf-test = pkgs.stdenv.mkDerivation {
          name = "nf-test";
          version = "0.9.2";

          src = pkgs.fetchurl {
            url = "https://github.com/askimed/nf-test/releases/download/v${nf-test.version}/nf-test-${nf-test.version}.tar.gz";
            hash = "sha256-v7LgbfKdTvQbMcs1ajdKmSQr742YQ0uL4wN79rPV1No=";
          };

          nativeBuildInputs = [ pkgs.makeWrapper ];

          unpackPhase = ''
            mkdir nf-test
            tar -xzf $src -C nf-test
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp nf-test/* $out

            makeWrapper $out/nf-test $out/bin/nf-test \
              --set JAVA_HOME ${pkgs.jdk11}
          '';
        };

        # nixpkgs' Groovy doesn't work with newer JDKs
        groovy = pkgs.groovy.override { jdk = pkgs.jdk11; };
      in
      {
        devShells.default = (pkgs.buildFHSUserEnv {
          name = "nextflow";

          targetPkgs = pkgs: [
            groovy
            nextflow
            nf-test
          ];
        }).env;
      }
    );
}
