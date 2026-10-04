{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      packages = nixpkgs.lib.genAttrs supportedSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          oci-image-content = pkgs.symlinkJoin {
            name = "oci-image-content";
            paths = [
              # Basic packages to let us comfortably use shell in this container:
              pkgs.bash
              pkgs.coreutils-full
              pkgs.procps
              pkgs.iana-etc
              pkgs.cacert

              # Kubernetes CLIs:
              pkgs.kubectl # https://github.com/kubernetes/kubectl # Kubernetes CLI

              # Data manipulation:
              pkgs.gawk # https://www.gnu.org/software/gawk/ # GNU implementation of the Awk programming language
              pkgs.jq # https://github.com/jqlang/jq # Lightweight and flexible command-line JSON processor
              pkgs.yq # https://github.com/kislyuk/yq # Command-line YAML/XML/TOML processor

              # Task runners
              pkgs.gnumake # https://www.gnu.org/software/make/ # Tool to control the generation of non-source files from sources
              pkgs.go-task # https://taskfile.dev/ # Task runner / simpler Make alternative written in Go
              pkgs.just # https://github.com/casey/just # Handy way to save and run project-specific commands

              # Packages for debugging applications:
              pkgs.curlFull
              pkgs.wget

              # ...
            ];
          };

          oci-image = pkgs.dockerTools.buildLayeredImage {
            name = "k8s-crash-cart";
            tag = "latest";

            contents = self.packages.${system}.oci-image-content;

            config = {
              WorkingDir = "/";
              Cmd = [ "/bin/bash" ];
            };
          };
        }
      );
    };
}
