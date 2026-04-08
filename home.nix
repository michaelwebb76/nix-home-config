{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  # Import other Nix files
  imports = [
    ./brew.nix
    ./git.nix
    ./shell.nix
    ./tmux.nix
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
      # Nix-specific packages (not practical to install via Homebrew)
      cachix # Nix build cache
      nix-direnv
      nixpkgs-fmt
      terraform # Deprecated in Homebrew due to BUSL license
      zsh-z

      # Everything else is installed via Homebrew.
      # Declared in brew.nix, which generates ~/.Brewfile.
      # After `home-manager switch`, sync with: brew bundle --global
    ];

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
    # Enable direnv config generation; binary installed via Homebrew
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      extraOptionOverrides = {
        AddKeysToAgent = "yes";
        IdentityFile = "${homePath}/.ssh/id_rsa";
        IgnoreUnknown = "UseKeychain";
        TCPKeepAlive = "yes";
        UseKeychain = "yes";
      };
      matchBlocks = {
        "bread-staging.trikeapps.com" = {
          controlMaster = "auto";
          serverAliveInterval = 120;
          user = "mike";
        };

        "*" = {
          addKeysToAgent = "no";
          compression = false;
          controlPath = "/tmp/ssh_mux_%h_%p_%r";
          controlPersist = "10";
          controlMaster = "auto";
          forwardAgent = true;
          hashKnownHosts = false;
          serverAliveCountMax = 3;
          serverAliveInterval = 120;
          userKnownHostsFile = "~/.ssh/known_hosts";
        };
      };
    };

    zsh.enable = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };
}
