{ config, lib, ... }:

let
  nigpkgsRev = "nixpkgs-unstable";
  pkgs = import (fetchTarball "https://github.com/nixos/nixpkgs/archive/${nigpkgsRev}.tar.gz") {};

  # Import other Nix files
  imports = [
    ./git.nix
    ./neovim.nix
    ./shell.nix
    ./tmux.nix
    ./vscode.nix
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
    delta
    diff-so-fancy
    git-codeowners
    gitflow
    gh
  ];

in {
  inherit imports;

  # Allow non-free (as in beer) packages
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  # Enable Home Manager
  programs.home-manager.enable = true;

  # Enable direnv
  programs.direnv.enable = true;
  programs.direnv.enableNixDirenvIntegration = true;
  programs.zsh.enable = true;
  programs.ssh = {
    controlMaster = "auto";
    controlPath = "/tmp/ssh_mux_%h_%p_%r";
    controlPersist = "10";
    enable = true;
    extraOptionOverrides = {
      AddKeysToAgent = "yes";
      ControlMaster = "auto";
      IdentityFile = "~/.ssh/id_rsa";
      IgnoreUnknown = "UseKeychain";
      TCPKeepAlive= "yes";
      UseKeychain = "yes";
    };
    forwardAgent = true;
    matchBlocks = {
      "pumpkin" = {
        user = "mike";
      };
    };
    serverAliveInterval = 120;
  };

  home = {
    username = "michaelwebb";
    homeDirectory = "/Users/michaelwebb";
    stateVersion = "21.05";
  };

  home.sessionVariables = {
    EDITOR = "code";
    TERMINAL = "alacritty";
  };

  # Miscellaneous packages (in alphabetical order)
  home.packages = with pkgs; [
    cachix # Nix build cache
    curl # An old classic
    fzf # Fuzzy matching
    gnupg # gpg for GNU/Linux
    graphviz # dot
    htop # Resource monitoring
    niv # Nix dependency management
    pinentry_mac # Necessary for GPG
    starship # Fancy shell that works with zsh
    terraform # Declarative infrastructure management
    tree # Should be included in macOS but it's not
    vscode # My fav text editor if I'm being honest
    wget
  ] ++ gitTools ++ scripts;
}
