# Git settings

{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Michael Webb";
    userEmail = "michaelwebb76@gmail.com";

    # Replaces ~/.gitignore
    ignores = [
      ".cache/"
      ".DS_Store"
      ".idea/"
      "*.swp"
      "built-in-stubs.jar"
      "dumb.rdb"
      ".vscode/"
      "npm-debug.log"
    ];

    # Global Git config
    extraConfig = {
      core = {
        editor = "vi";
        whitespace = "trailing-space,space-before-tab";
      };

      color.ui = "auto";

      push.autoSetupRemote = true;

      commit.gpgsign = "true";
      gpg.format = "ssh";
      user.signingkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDTNv8f/4xn1EVVinl7k1Rrtbg881byLfBotBeIGxj9F9YcTkhmhjkWdvITehrj/pAlmAtxmgK29P0r6BVWFzDoSImnhJe1OhkYx2mYmVKJPDq35scwG1fW3mzTYFIDblC+BzpnQOCS8BQxmvi3S74MyCDvlIltI1MgjKMlf87TlOlGE5dzxiGvC2zxK/NVDI7cKDi8yuja/CBH6wSMDVD2HUzVyvU3gZVeC/nCFYmHvdshS5IwJP6SVQiLDak5FJnqKv48Z2VURF7MCno9klshUxAPf1hT2AoC1Y8nHrQ+WYIupt1QmVGOHwh3MkvNB1rBcBhzAk6pSN0B6/h49bG6jPVz1f8HSjs0h1SZqga3QcNycCg3PCyxaTJaITzL7rsWpk+oMWfpc9hkdTUzVHvE8G2sCfgXWQd+IP8fM7ev3MweH5wk3Z8g/WTYNdtbRQ+EQoYslw3joPBGa0eC5uzmfwReHPR1BQEFA/uQqq/aelE5y2FmhxSJi1QJvXhAo/M= michaelwebb@Michaels-MBP.localdomain";

      protocol.keybase.allow = "always";
      credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
      pull.rebase = "false";
    };
  };
}
