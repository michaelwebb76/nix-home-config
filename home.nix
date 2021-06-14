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

  rubyPackages = with pkgs.rubyPackages_2_6; [
    pry
    rails
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
    autoconf # Broadly used tool, no clue what it does
    bash # /bin/bash
    cachix # Nix build cache
    conftest
    curl # An old classic
    direnv # Per-directory environment variables
    gnupg # gpg for GNU/Linux
    graphviz # dot
    htop # Resource monitoring
    lorri # Easy Nix shell
    ngrok-1 # Expose local HTTP stuff publicly
    niv # Nix dependency management
    nodejs # node and npm
    pinentry_mac # Necessary for GPG
    starship # Fancy shell that works with zsh
    terraform # Declarative infrastructure management
    tree # Should be included in macOS but it's not
    vscode # My fav text editor if I'm being honest
    wget
    yarn # Node.js package manager
  ] ++ gitTools ++ rubyPackages ++ scripts;
}
