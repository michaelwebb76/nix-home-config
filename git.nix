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
      gpg.format = "ssh";
      user.signingkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNl+0Y7ARbG7GQymPnr7gsLiR7oV4nTTiuJlQIoO/8A5j8YL+Sx6K36lTcC1YBA7irSXRqhEQlqm9s2y9A6UmWMQvIkbgsdPUeWT2g5jn6CcrriXgJXMOO84balpG0aQnxjGZXuAJusvlMdQJ7LIKIT06weKVaVDLqk4vW6+zqtPCRt2hp0eINqr4M1qW6xvOD296Y2iSgyrwWshQWis3onwVeZOME6ztpmNgJWfoWBsSCXEvfioBjCsse8f4u4NUZe5m/XiVM7ix5nl+3W+QM0c/EWX/+0hBUJRSGB7y3uQk7JzLPMPYpwgas44bMtGRIe5RrwAs+d4rvSs8b3tU4Vb7PbR42iMFWMeva3Ch7kl+vNYhtHzWqP0yh2Zgkw0ub14KshgwLr8ZfelZ7wW5g/jd/z5y4nhyWqiRLuiZTOMES1zvwrZWrOhAOo5ebsPyGq/jD9H9kWTXY8fJc5ZqSPnPaWEvQCHBVy4lMqXcJCYU7qIavwGj0VO1EUF2unZAZZLSENKL19ftOmGJRZE5AVkZmiiw4AEo5FKsbROtuAFRenxS5Kusbz5tfXID2nLvlDnLgUyfY19G2/l4S9kS4TLSkDRSxawoxOGdb+KK9On3697vl/gYAsVeDrdSOaldCJCAdBAJv2FW/ssGg+7QLlb+7G1phHs2Jx9M2VPx52Q== michaelwebb@192-168-1-108.tpgi.com.au";

      protocol.keybase.allow = "always";
      credential.helper = "${
        pkgs.git.override { withLibsecret = true; }
      }/bin/git-credential-libsecret";
      pull.rebase = "false";
    };
  };
}
