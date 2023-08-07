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

  autostartPrograms = [ pkgs.albert pkgs.slack ];

  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';

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
        IdentityFile = "/home/mike/.ssh/id_rsa";
        IgnoreUnknown = "UseKeychain";
        TCPKeepAlive = "yes";
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
  };

  wayland.windowManager.sway = {
    enable = true;
  };

  home = {
    username = "mike";
    homeDirectory = "/home/mike";
    stateVersion = "23.05";
    sessionVariables = {
      EDITOR = "code --enable-features=UseOzonePlatform --ozone-platform=wayland";
      TERMINAL = "alacritty";
    };

    file = builtins.listToAttrs (map
      (pkg:
        {
          name = ".config/autostart/" + pkg.pname + ".desktop";
          value =
            if pkg ? desktopItem then {
              # Application has a desktopItem entry.
              # Assume that it was made with makeDesktopEntry, which exposes a
              # text attribute with the contents of the .desktop file
              text = pkg.desktopItem.text;
            } else {
              # Application does *not* have a desktopItem entry. Try to find a
              # matching .desktop name in /share/apaplications
              source = (pkg + "/share/applications/" + pkg.pname + ".desktop");
            };
        })
      autostartPrograms);

    # Miscellaneous packages (in alphabetical order)
    packages = with pkgs; [
      _1password
      _1password-gui
      albert
      audacity # Audio editor
      cachix # Nix build cache
      curl # An old classic
      dbeaver # Database client
      docker-compose
      fira-code
      fira-mono
      firefox
      fzf # Fuzzy matching
      gimp
      gnome3.gnome-power-manager
      gnome3.gnome-shell-extensions
      gnome3.gnome-tweaks
      gnome3.libgnome-keyring
      gnomeExtensions.emoji-selector
      gnomeExtensions.timezones-extension
      google-chrome
      graphviz # dot
      haruna
      haskellPackages.cabal-install
      htop # Resource monitoring
      networkmanagerapplet
      niv # Nix dependency management
      nix-direnv
      nixpkgs-fmt
      nss.tools
      nvidia-offload
      obs-studio # Desktop recording
      obsidian # Notes wiki
      pinentry
      skypeforlinux
      slack
      spotify
      starship # Fancy shell that works with zsh
      terraform # Declarative infrastructure management
      tree # Should be included in macOS but it's not
      vscode
      watchman
      wget
      zoom-us
      zsh-z
    ] ++ gitTools ++ scripts;
  };
}
