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
    reload = "NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure --extra-experimental-features nix-command && brew bundle --global && source ~/.zshrc";

    # Nix garbage collection + Homebrew cleanup
    garbage = "nix-collect-garbage -d && brew cleanup";

    # Bundle Rails C
    brc = "bundle exec rails c";
    # Bundle Rails S
    brs = "bundle exec rails s";
    # Database MigrAte
    dma = "bundle exec rake db:migrate";
    # Database (M) Rollback
    dmr = "bundle exec rake db:rollback";
    # HooGLe server
    hgl = "hoogle server --local --port 8080 &";
  };
in
{
  # broot and starship are installed via Homebrew; configure them below.

  # Starship prompt configuration
  home.file.".config/starship.toml".text = ''
    right_format = "$time"

    [time]
    disabled = false
    format = "[$time]($style) "
    time_format = "%T"
    style = "bold yellow"
  '';

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

      # Homebrew setup (must come before any Homebrew-installed tool init)
      if [ -e '/opt/homebrew/bin/brew' ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      # Broot shell integration (installed via Homebrew)
      if [ -f "$HOME/Library/Application Support/org.dystroy.broot/launcher/bash/br" ]; then
        source "$HOME/Library/Application Support/org.dystroy.broot/launcher/bash/br"
      fi

      # Starship prompt (installed via Homebrew)
      eval "$(starship init zsh)"

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

      # direnv setup
      eval "$(direnv hook zsh)"

      # Copy dist folders from the main worktree if they're not already present
      function _ensure_dist() {
        local main_worktree
        main_worktree=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's|/\.git$||')
        if [[ -z "$main_worktree" ]]; then
          return 0
        fi
        local current_dir
        current_dir=$(pwd)
        if [[ "$current_dir" == "$main_worktree" ]]; then
          return 0
        fi
        for dist_dir in dist-newstyle dist-debug; do
          if [[ ! -d "$dist_dir" && -d "$main_worktree/$dist_dir" ]]; then
            echo "Copying $dist_dir from main worktree..."
            cp -r "$main_worktree/$dist_dir" "$dist_dir"
          fi
        done
      }

      # Build and test a Haskell project
      function hbt() {
        TOOL_NAME=$1
        _ensure_dist
        clear && cabal build $TOOL_NAME && cabal test $TOOL_NAME
      }

      # Build, test, and install a Haskell tool
      function hbti() {
        TOOL_NAME=$1
        _ensure_dist
        clear && cabal build $TOOL_NAME && cabal test $TOOL_NAME && cabal install $TOOL_NAME --overwrite-policy=always
      }

      # Debug a Haskell project with ghcid
      function hdbg() {
        TOOL_NAME=$1
        _ensure_dist
        ghcid -c "cabal repl --enable-multi-repl --ghc-options=-Wwarn --builddir=./dist-debug $TOOL_NAME"
      }

      # Run the Haskell REPL
      function hrepl() {
        TOOL_NAME=$1
        _ensure_dist
        cabal repl --enable-multi-repl --ghc-options=-Wwarn --builddir=./dist-debug $TOOL_NAME
      }

      # Do cabal run
      function hbr() {
        TOOL_NAME=$1
        _ensure_dist
        cabal run $TOOL_NAME -- ''${@:2}
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
        local worktree_path=".worktrees/$branch_name"

        # Create the git worktree
        echo "Creating git worktree for branch '$branch_name'..."
        git worktree add -b "$branch_name" "$worktree_path"

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

        # Copy dist directory if it exists
        if [[ -d dist-newstyle ]]; then
          echo "Copying dist-newstyle..."
          cp -r dist-newstyle "$worktree_path/"
        fi

        # Copy vendor directory if it exists
        if [[ -d vendor ]]; then
          echo "Copying vendor..."
          cp -r vendor "$worktree_path/"
        fi

        # Copy pre-commit config symlink if it exists
        if [[ -L .pre-commit-config.yaml ]]; then
          echo "Copying .pre-commit-config.yaml symlink..."
          local target=$(readlink .pre-commit-config.yaml)
          ln -sf "$target" "$worktree_path/.pre-commit-config.yaml"
        fi

        echo "Git worktree setup complete!"
      }

      # Symlink .envrc and .direnv from the main worktree if they're not already present
      function direnvy() {
        local main_worktree
        main_worktree=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's|/\.git$||')
        if [[ -z "$main_worktree" ]]; then
          echo "Error: Not in a git repository"
          return 1
        fi
        local current_dir
        current_dir=$(pwd)
        if [[ "$current_dir" == "$main_worktree" ]]; then
          echo "Already in the main worktree, nothing to symlink"
          return 0
        fi
        if [[ ! -e .envrc && -e "$main_worktree/.envrc" ]]; then
          echo "Symlinking .envrc from main worktree..."
          ln -s "$main_worktree/.envrc" .envrc
          echo "Running direnv allow..."
          direnv allow
        else
          echo ".envrc already exists (or not present in main worktree), nothing to symlink"
        fi
      }

      # Remove a git worktree, its directory, and its branch
      function kill-worktree() {
        if [[ -z "$1" ]]; then
          echo "Usage: kill-worktree <worktree-name>"
          return 1
        fi

        local branch_name="$1"

        # Find the worktree path from git
        local worktree_path
        worktree_path=$(git worktree list --porcelain | awk -v branch="refs/heads/$branch_name" '/^worktree /{wt=$0; sub(/^worktree /, "", wt)} /^branch /{if ($2 == branch) print wt}')

        if [[ -z "$worktree_path" ]]; then
          echo "Error: No worktree found for branch '$branch_name'"
          return 1
        fi

        echo "Removing worktree at: $worktree_path"
        git worktree remove "$worktree_path" --force

        if [[ -d "$worktree_path" ]]; then
          echo "Directory still exists, removing: $worktree_path"
          rm -rf "$worktree_path"
        fi

        echo "Deleting branch: $branch_name"
        git branch -D "$branch_name"

        echo "Done! Worktree and branch '$branch_name' removed."
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
