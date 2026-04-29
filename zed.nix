# Zed editor settings.
#
# The settings/keymap files live in this repo and are symlinked into place
# via mkOutOfStoreSymlink so edits made in Zed write back to the repo
# directly (rather than into the read-only Nix store).

{ config, ... }:

let
  repoPath = "${config.home.homeDirectory}/.config/home-manager";
in
{
  home.file = {
    ".config/zed/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${repoPath}/zed/settings.json";
    ".config/zed/keymap.json".source =
      config.lib.file.mkOutOfStoreSymlink "${repoPath}/zed/keymap.json";
  };
}
