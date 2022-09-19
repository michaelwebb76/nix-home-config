# Shell configuration for zsh (frequently used)

{ config, lib, pkgs, ... }:

let
  # Set all shell aliases programatically
  shellAliases = {
    # Aliases for commonly used tools
    grep = "grep --color=auto";
    just = "just --no-dotenv";
    iex = "iex --dot-iex ~/.iex.exs";
    ll = "ls -lh";
    tf = "terraform";
    hms = "home-manager switch";

    # Reload zsh
    szsh = "source ~/.zshrc";

    # Reload home manager and zsh
    reload = "NIXPKGS_ALLOW_UNFREE=1 home-manager switch && source ~/.zshrc";

    # Nix garbage collection
    garbage = "nix-collect-garbage -d && docker image prune --force";

    # See which Nix packages are installed
    installed = "nix-env --query --installed";

    brc = "bundle exec rails c";
    brs = "bundle exec rails s";
    dma = "bundle exec rake db:migrate";
    dmr = "bundle exec rake db:rollback";
    vsc = "code . --enable-features=UseOzonePlatform --ozone-platform=wayland";
    hgl = "hoogle server --local --port 8080 &";
  };
in {
  # Fancy filesystem navigator
  programs.broot = {
    enable = true;
    enableZshIntegration = true;
  };

  # zsh settings
  programs.zsh = {
    inherit shellAliases;
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    history.extended = true;

    # Called whenever zsh is initialized
    initExtra = ''
      export TERM="xterm-256color"
      bindkey -e

      # Nix setup (environment variables, etc.)
      if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi

      # Load environment variables from a file; this approach allows me to not
      # commit secrets like API keys to Git
      if [ -e ~/.env ]; then
        . ~/.env
      fi

      # Start up Starship shell
      eval "$(starship init zsh)"

      # direnv setup
      eval "$(direnv hook zsh)"

      # direnv hook
      eval "$(direnv hook zsh)"
    '';

    oh-my-zsh = {
     enable = true;
     plugins = [
       "git"
       "bundler"
       "gem"
       "powder"
       "rake"
       "themes"
       "history"
       "z"
       "brew"
     ];
     theme = "muse";
    };
  };
}
