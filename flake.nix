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
            paths = with pkgs; [
              # Basic packages to let us comfortably use shell in this container:
              bash # https://www.gnu.org/software/bash/ # GNU Bourne-Again Shell; package for interactive use.
              cacert # Bundle of X.509 certificates of public Certificate Authorities (CA)
              htop # https://github.com/htop-dev/htop # Interactive process viewer
              iana-etc # https://github.com/Mic92/iana-etc # IANA protocol and port number assignments (/etc/protocols and /etc/services)
              procps # https://gitlab.com/procps-ng/procps # Utilities that give information about processes using the /proc filesystem
              uutils-coreutils-noprefix # https://github.com/uutils/coreutils # Cross-platform Rust rewrite of the GNU coreutils

              # Kubernetes-specific CLIs:
              k9s # https://github.com/derailed/k9s # Kubernetes CLI To Manage Your Clusters In Style
              kubectl # https://github.com/kubernetes/kubectl # Kubernetes CLI
              kubectl-gadget # https://github.com/inspektor-gadget/inspektor-gadget # Troubleshoot K8S applications using eBPF
              stern # https://github.com/stern/stern # Multi pod and container log tailing for Kubernetes

              # Networking and system utilities (these will be heavily restricted within a container, but may still be useful):
              iproute2 # https://wiki.linuxfoundation.org/networking/iproute2 # Utilities for controlling TCP/IP networking
              iputils # https://github.com/iputils/iputils # Set of small useful utilities for Linux networking
              libressl # https://www.libressl.org # Free TLS/SSL implementation. Includes `nc`, `ocspcheck` and `openssl` CLIs.
              lsof # https://github.com/lsof-org/lsof # Tool to list open files
              mtr # https://github.com/traviscross/mtr # Network diagnostics tool
              strace # https://github.com/strace/strace # System call tracer for Linux
              sysstat # https://github.com/sysstat/sysstat # Performance monitoring tools, e.g. `sar`, `iostat` and `pidstat`
              tcpdump # https://www.tcpdump.org/ # Network sniffer
              dnslookup # https://github.com/ameshkov/dnslookup # Simple CLI to make DNS lookups to the specified server

              # Text editors:
              nano # https://www.nano-editor.org/ # Small, user-friendly console text editor
              vim # https://www.vim.org/ # Most popular clone of the VI editor

              # Script runtimes:
              nodejs # https://nodejs.org/ # Event-driven I/O framework for the V8 JavaScript engine

              # Task runners
              gnumake # https://www.gnu.org/software/make/ # Tool to control the generation of non-source files from sources
              go-task # https://taskfile.dev/ # Task runner / simpler Make alternative written in Go
              just # https://github.com/casey/just # Handy way to save and run project-specific commands

              # Data manipulation:
              gawk # https://www.gnu.org/software/gawk/ # GNU implementation of the Awk programming language
              jq # https://github.com/jqlang/jq # Lightweight and flexible command-line JSON processor
              yq # https://github.com/kislyuk/yq # Command-line YAML/XML/TOML processor

              # Testing connectors to application:
              curlFull # https://curl.se/ # Command line tool for transferring files with URL syntax
              wget # https://www.gnu.org/software/wget/ # Tool for retrieving files using HTTP, HTTPS, and FTP

              # Traffic capture and generation:
              k6 # https://github.com/grafana/k6 # Modern load testing tool, using Go and JavaScript
              har-to-k6 # https://github.com/grafana/har-to-k6 # Converts LI-HAR and HAR to K6 script
              goreplay # https://github.com/probelabs/goreplay # Open-source tool for capturing and replaying live HTTP traffic

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
