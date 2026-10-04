{ pkgs, ... }:
{
  # See full reference at https://devenv.sh/reference/options/

  # https://devenv.sh/languages/
  languages = {
    nix = {
      enable = true;
      lsp.package = pkgs.nixd;
    };
  };

  # https://devenv.sh/packages/
  # https://search.nixos.org/packages
  packages = with pkgs; [
    git
    gnupg

    go-task # https://taskfile.dev/ # Task runner / simpler Make alternative written in Go
    sbomnix # https://github.com/tiiuae/sbomnix # Utilities to help with software supply chain challenges on nix targets
  ];

  git-hooks.hooks = {
    # Basics
    gitlint.enable = true;
    no-commit-to-branch.enable = false;
    trufflehog.enable = true;

    # Keep nix files nice and tidy
    deadnix.enable = true;
    nixfmt.enable = true;
    shellcheck.enable = true;
    statix.enable = true;

    # Keep Github Actions nice and tidy
    actionlint.enable = true;
    zizmor.enable = true;

    # Additional formatters
    markdownlint = {
      enable = true;
      settings.configuration = {
        MD013 = {
          line_length = 120;
        };
        MD033 = false;
        MD034 = false;
      };
    };
    yamllint = {
      enable = true;
      settings.configuration = ''
        extends: relaxed
        rules:
          line-length:
            max: 180
      '';
    };
  };

  enterShell = ''
    # Do nothing
  '';

  enterTest = ''
    # Do nothing
  '';
}
