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

    # Homebrew's aws-sso-util ships its own Python; the Haskell devshell's
    # PYTHONPATH leaks Nix 3.13 site-packages into it and breaks the rpds
    # C extension. Strip PYTHONPATH for this tool.
    aws-sso-util = "env -u PYTHONPATH aws-sso-util";

    # Reload zsh
    szsh = "source ~/.zshrc";

    # Reload home manager and zsh
    reload = "NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure --extra-experimental-features nix-command && HOMEBREW_GITHUB_API_TOKEN=$(gh auth token) brew bundle --global && source ~/.zshrc";

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

      # Build a Haskell project
      function hb() {
        clear && cabal build "$@"
      }

      # Build and test a Haskell project
      function hbt() {
        clear && cabal build "$@" && cabal test "$@"
      }

      # Build, test, and install a Haskell tool
      function hbti() {
        clear && cabal build "$@" && cabal test "$@" && cabal install "$@" --overwrite-policy=always
      }

      # Debug a Haskell project with ghcid
      function hdbg() {
        ghcid -c "cabal repl --enable-multi-repl --ghc-options=-Wwarn --builddir=./dist-debug $@"
      }

      # Run the Haskell REPL
      function hrepl() {
        cabal repl --enable-multi-repl --ghc-options=-Wwarn --builddir=./dist-debug "$@"
      }

      # Do cabal run
      function hbr() {
        TOOL_NAME=$1
        cabal run $TOOL_NAME -- ''${@:2}
      }

      # Remove a git worktree, its directory, and its branch
      function kill-worktree() {
        if [[ -z "$1" ]]; then
          echo "Usage: kill-worktree <worktree-name>"
          return 1
        fi

        local branch_name="$1"

        # Find the worktree path from git
        local worktree_list
        worktree_list=$(git worktree list --porcelain)

        local worktree_path
        worktree_path=$(echo "$worktree_list" | awk -v branch="refs/heads/$branch_name" '/^worktree /{wt=$0; sub(/^worktree /, "", wt)} /^branch /{if ($2 == branch) print wt}')

        if [[ -z "$worktree_path" ]]; then
          echo "Error: No worktree found for branch '$branch_name'"
          return 1
        fi

        if [[ "$worktree_path" == *$'\n'* ]]; then
          echo "Error: Multiple worktrees matched branch '$branch_name', refusing to proceed:"
          echo "$worktree_path"
          return 1
        fi

        # Never operate on the main worktree - it's always the first entry
        # git worktree list reports, and git refuses to remove it anyway, but
        # we check explicitly so we never fall through to `rm -rf` on it.
        local main_worktree
        main_worktree=$(echo "$worktree_list" | awk '/^worktree /{print substr($0, 10); exit}')
        if [[ "$worktree_path" == "$main_worktree" ]]; then
          echo "Error: '$branch_name' resolves to the main worktree ($worktree_path) - refusing to remove it."
          return 1
        fi

        echo "Removing worktree at: $worktree_path"
        if ! git worktree remove "$worktree_path" --force; then
          echo "Error: 'git worktree remove' failed - leaving '$worktree_path' in place. Resolve manually before retrying."
          return 1
        fi

        if [[ -d "$worktree_path" ]]; then
          echo "Directory still exists, removing: $worktree_path"
          rm -rf "$worktree_path"
        fi

        local parent_dir
        parent_dir=$(dirname "$worktree_path")
        if [[ -d "$parent_dir" ]] && [[ -z "$(ls -A "$parent_dir")" ]]; then
          echo "Parent directory is empty, removing: $parent_dir"
          rmdir "$parent_dir"
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
