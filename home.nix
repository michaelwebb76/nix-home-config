{ config, pkgs, ... }:

let
  # Import other Nix files
  imports = [
    ./git.nix
    ./shell.nix
    ./tmux.nix
  ];

  gitTools = with pkgs.gitAndTools; [
    gh
  ];

  userName = "michaelwebb";
  homePath = "/Users/${userName}";
in
{
  inherit imports;

  home = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    username = "${userName}";
    homeDirectory = "${homePath}";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.11"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      # # Adds the 'hello' command to your environment. It prints a friendly
      # # "Hello, world!" when run.
      # pkgs.hello

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
      awscli2
      cachix # Nix build cache
      curl # An old classic
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
    ] ++ gitTools;

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      ".config/cabal/config".text = ''
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
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. If you don't want to manage your shell through Home
    # Manager then you have to manually source 'hm-session-vars.sh' located at
    # either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/michaelwebb/etc/profile.d/hm-session-vars.sh
    #
    sessionVariables = {
      EDITOR = "code";
      TERMINAL = "alacritty";
    };
  };

  # Let Home Manager install and manage itself.
  programs = {
    # Enable direnv
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
        package = pkgs.nix-direnv.override {
          # 2024-06-05 @Luke Worth 4:04 PM
          # 2024-06-05 nix-direnv uses the default version of nix by default, which is a version that’s stuffed
          # 2024-06-05 @mike 4:05 PM
          # 2024-06-05 Is 2_22 an older version than that one or a newer version?
          # 2024-06-05 @Luke Worth 4:05 PM
          # 2024-06-05 It took me a while to work that out
          # 2024-06-05 It’s newer
          # 2024-06-05 @mike 4:05 PM
          # 2024-06-05 Thank you for sharing then
          # 2024-06-05 @Luke Worth 4:05 PM
          # 2024-06-05 The dfault is 2.18 or something
          nix = pkgs.nixVersions.nix_2_22;
        };
      };
    };

    home-manager.enable = true;

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

    zsh.enable = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };
}
