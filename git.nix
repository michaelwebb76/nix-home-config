# Git settings

{ config, lib, pkgs, ... }:

let
  vscode = pkgs.vscode;
in {
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
        editor = "code --wait";
        whitespace = "trailing-space,space-before-tab";
      };

      commit.gpgsign = "true";
      gpg.program = "gpg2";

      protocol.keybase.allow = "always";
      credential.helper = "${
        pkgs.git.override { withLibsecret = true; }
      }/bin/git-credential-libsecret";
      pull.rebase = "false";
    };
  };
}
