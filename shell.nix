# Shell configuration for zsh (frequently used)

{ config, lib, pkgs, ... }:

let
  # Set all shell aliases programatically
  shellAliases = {
    # Aliases for commonly used tools
    grep = "grep --color=auto";
    ll = "ls -lh";
    tf = "terraform";
    hms = "home-manager switch";

    # Reload zsh
    szsh = "source ~/.zshrc";

    # Reload home manager and zsh
    reload = "NIXPKGS_ALLOW_UNFREE=1 home-manager switch && source ~/.zshrc";

    # Nix garbage collection
    garbage = "nix-collect-garbage -d";

    # Bundle Rails C
    brc = "bundle exec rails c";
    # Bundle Rails S
    brs = "bundle exec rails s";
    # Database MigrAte
    dma = "bundle exec rake db:migrate";
    # Database (M) Rollback
    dmr = "bundle exec rake db:rollback";
    # Visual Studio Code
    vsc = "code .";
    # HooGLe server
    hgl = "hoogle server --local --port 8080 &";
  };
in
{
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

    initExtraFirst = ''
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/
    '';

    # Called whenever zsh is initialized
    initExtra = ''
      export TERM="xterm-256color"
      bindkey -e

      # Nix setup (environment variables, etc.)
      # https://discourse.nixos.org/t/how-to-restore-nix-and-home-manager-after-macos-upgrade/25474
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
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

      # Build and test a Haskell project
      function hbt() {
        echo "optimization: False" > cabal.project.local
        echo "program-options" >> cabal.project.local
        echo "  ghc-options: -Wall" >> cabal.project.local

        TOOL_NAME=$1
        clear && cabal --builddir=./dist-newstyle build $TOOL_NAME && cabal --builddir=./dist-newstyle test $TOOL_NAME
      }

      # Build, test, and install a Haskell tool
      function hbti() {
        echo "optimization: False" > cabal.project.local
        echo "program-options" >> cabal.project.local
        echo "  ghc-options: -Wall" >> cabal.project.local

        TOOL_NAME=$1
        clear && cabal --builddir=./dist-newstyle build $TOOL_NAME && cabal --builddir=./dist-newstyle test $TOOL_NAME && cabal --builddir=./dist-newstyle install $TOOL_NAME --overwrite-policy=always
      }

      # Debug a Haskell project with ghcid
      function hdbg() {
        echo "optimization: False" > cabal.project.local
        echo "program-options" >> cabal.project.local
        echo "  ghc-options: -Wwarn -Wunused-top-binds -Werror=unused-top-binds" >> cabal.project.local

        TOOL_NAME=$1
        ghcid -c "cabal --builddir=./dist-newstyle-debug repl $TOOL_NAME"
      }

      PATH=$PATH:~/.local/bin
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
