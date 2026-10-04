{
  description = "Kubernetes Application Crash Cart";

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
              pkgs.k9s # https://github.com/derailed/k9s # Kubernetes CLI To Manage Your Clusters In Style

              # Text editors:
              pkgs.nano # https://www.nano-editor.org/ # Small, user-friendly console text editor
              pkgs.vim # https://www.vim.org/ # Most popular clone of the VI editor

              # Script runtimes:
              pkgs.nodejs # https://nodejs.org/ # Event-driven I/O framework for the V8 JavaScript engine

              # Task runners
              pkgs.gnumake # https://www.gnu.org/software/make/ # Tool to control the generation of non-source files from sources
              pkgs.go-task # https://taskfile.dev/ # Task runner / simpler Make alternative written in Go
              pkgs.just # https://github.com/casey/just # Handy way to save and run project-specific commands

              # Data manipulation:
              pkgs.gawk # https://www.gnu.org/software/gawk/ # GNU implementation of the Awk programming language
              pkgs.jq # https://github.com/jqlang/jq # Lightweight and flexible command-line JSON processor
              pkgs.yq # https://github.com/kislyuk/yq # Command-line YAML/XML/TOML processor

              # Testing connectors to application:
              pkgs.curlFull # https://curl.se/ # Command line tool for transferring files with URL syntax
              pkgs.wget # https://www.gnu.org/software/wget/ # Tool for retrieving files using HTTP, HTTPS, and FTP

              # Traffic generation:
              pkgs.k6 # https://github.com/grafana/k6 # Modern load testing tool, using Go and JavaScript
              pkgs.har-to-k6 # https://github.com/grafana/har-to-k6 # Converts LI-HAR and HAR to K6 script

              # Traffic capture:
              pkgs.goreplay # https://github.com/probelabs/goreplay # Open-source tool for capturing and replaying live HTTP traffic
              pkgs.tcpdump # https://www.tcpdump.org/ # Network sniffer

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
