# Shell configuration for zsh (frequently used)

{
  config,
  lib,
  pkgs,
  ...
}:

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
    reload = "NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure --extra-experimental-features nix-command && source ~/.zshrc";

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
    autosuggestion.enable = true;
    enableCompletion = true;
    history.extended = true;

    # Called whenever zsh is initialized
    initContent = lib.mkBefore ''
      export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/
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

      function setCabalProjectLocalToBuild() {
        echo "optimization: False" > cabal.project.local
        echo "program-options" >> cabal.project.local
        echo "  ghc-options: -Wall" >> cabal.project.local
      }

      function setCabalProjectLocalToDebug() {
        echo "optimization: False" > cabal.project.local
        echo "program-options" >> cabal.project.local
        echo "  ghc-options: -Wwarn -Wunused-top-binds -Werror=unused-top-binds" >> cabal.project.local
      }

      function setCabalProjectLocalToCoverage() {
        echo "package *" >> cabal.project.local
        echo "  coverage: True" >> cabal.project.local
        echo "  library-coverage: True" >> cabal.project.local
        echo "package order-processing" >> cabal.project.local
        echo "  coverage: False" >> cabal.project.local
        echo "  library-coverage: False" >> cabal.project.local
      }

      # Build and test a Haskell project
      function hbt() {
        setCabalProjectLocalToBuild

        TOOL_NAME=$1
        clear && cabal --builddir=./dist-build build $TOOL_NAME && cabal --builddir=./dist-build test $TOOL_NAME
      }

      # Build, test, and install a Haskell tool
      function hbti() {
        setCabalProjectLocalToBuild

        TOOL_NAME=$1
        clear && cabal --builddir=./dist-build build $TOOL_NAME && cabal --builddir=./dist-build test $TOOL_NAME && cabal --builddir=./dist-build install $TOOL_NAME --overwrite-policy=always
      }

      # Debug a Haskell project with ghcid
      function hdbg() {
        setCabalProjectLocalToDebug

        TOOL_NAME=$1
        ghcid -c "cabal --builddir=./dist-debug repl $TOOL_NAME"
      }

      # Run the Haskell REPL
      function hrepl() {
        setCabalProjectLocalToDebug

        TOOL_NAME=$1
        cabal --builddir=./dist-debug repl $TOOL_NAME
      }

      # Run tests with coverage
      function hbtc() {
        setCabalProjectLocalToBuild
        setCabalProjectLocalToCoverage

        TOOL_NAME=$1
        cabal --builddir=./dist-coverage build $TOOL_NAME && cabal --builddir=./dist-coverage test $TOOL_NAME
      }

      # Do cabal run
      function hbr() {
        setCabalProjectLocalToBuild

        TOOL_NAME=$1
        cabal --builddir=./dist-build run $TOOL_NAME -- ''${@:2}
      }

      # Create git worktree with Haskell project files
      function gt() {
        # Check if we're in a git repository root
        if [[ ! -d .git ]]; then
          echo "Error: Not in a git repository root directory"
          return 1
        fi

        # Require branch name argument
        if [[ -z "$1" ]]; then
          echo "Usage: gt <branch-name>"
          echo "Creates a git worktree and copies Haskell build artifacts if present"
          return 1
        fi

        local branch_name="$1"
        local worktree_path="../$branch_name"

        # Create the git worktree
        echo "Creating git worktree for branch '$branch_name'..."
        git worktree add "$worktree_path" "$branch_name"

        if [[ $? -ne 0 ]]; then
          echo "Failed to create git worktree"
          return 1
        fi

        echo "Worktree created at: $worktree_path"

        # Copy cabal.project.local if it exists
        if [[ -f cabal.project.local ]]; then
          echo "Copying cabal.project.local..."
          cp cabal.project.local "$worktree_path/"
        fi

        # Copy dist directories if they exist
        for dist_dir in dist-newstyle dist-build dist-debug; do
          if [[ -d "$dist_dir" ]]; then
            echo "Copying $dist_dir..."
            cp -r "$dist_dir" "$worktree_path/"
          fi
        done

        echo "Git worktree setup complete!"
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
