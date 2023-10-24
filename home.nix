{ config, lib, ... }:

let
  nixpkgsRev = "23.05";
  pkgs = import (fetchTarball "https://github.com/nixos/nixpkgs/archive/${nixpkgsRev}.tar.gz") { };

  # Import other Nix files
  imports = [
    ./git.nix
    ./neovim.nix
    ./shell.nix
    ./tmux.nix
  ];

  # Handly shell command to view the dependency tree of Nix packages
  depends = pkgs.writeScriptBin "depends" ''
    dep=$1
    nix-store --query --requisites $(which $dep)
  '';


  git-hash = pkgs.writeScriptBin "git-hash" ''
    nix-prefetch-url --unpack https://github.com/$1/$2/archive/$3.tar.gz
  '';

  wo = pkgs.writeScriptBin "wo" ''
    readlink $(which $1)
  '';

  run = pkgs.writeScriptBin "run" ''
    nix-shell --pure --run "$@"
  '';

  scripts = [
    depends
    git-hash
    run
    wo
  ];

  gitTools = with pkgs.gitAndTools; [
    gh
  ];

  userName = "michaelwebb";
  homePath = "/Users/${userName}";
in
{
  inherit imports;

  # Allow non-free (as in beer) packages
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  # Enable Home Manager
  programs = {
    home-manager.enable = true;

    # Enable direnv
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zsh.enable = true;
    ssh = {
      controlMaster = "auto";
      controlPath = "/tmp/ssh_mux_%h_%p_%r";
      controlPersist = "10";
      enable = true;
      extraOptionOverrides = {
        AddKeysToAgent = "yes";
        ControlMaster = "auto";
        IdentityFile = "${homePath}/.ssh/id_rsa";
        IgnoreUnknown = "UseKeychain";
        TCPKeepAlive = "yes";
        UseKeychain = "yes";
      };
      forwardAgent = true;
      matchBlocks = {
        "bread-staging.trikeapps.com" = {
          user = "mike";
        };
      };
      serverAliveInterval = 120;
    };
  };

  home = {
    username = "${userName}";
    homeDirectory = "${homePath}";
    stateVersion = "23.05";
    sessionVariables = {
      EDITOR = "code";
      TERMINAL = "alacritty";
    };

    file.".config/cabal/config".text = ''
      build-summary: ${homePath}/.cache/cabal/logs/build.log
      extra-prog-path: ${homePath}/.local/bin
      installdir: ${homePath}/.local/bin
      jobs: $ncpus
      nix: disable
      remote-build-reporting: none
      remote-repo-cache: ${homePath}/.cache/cabal/packages
      repository hackage.haskell.org
        url: http://hackage.haskell.org/
    '';

    # Miscellaneous packages (in alphabetical order)
    packages = with pkgs; [
      awscli2
      cachix # Nix build cache
      curl # An old classic
      dbeaver # Database client
      fira-code
      fira-mono
      fzf # Fuzzy matching
      graphviz # dot
      haskellPackages.cabal-install
      htop # Resource monitoring
      niv # Nix dependency management
      nix-direnv
      nixpkgs-fmt
      nss.tools
      obsidian # Notes wiki
      starship # Fancy shell that works with zsh
      terraform # Declarative infrastructure management
      tree # Should be included in macOS but it's not
      watchman
      wget
      zsh-z
    ] ++ gitTools ++ scripts;
  };
}
