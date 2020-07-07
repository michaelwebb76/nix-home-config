{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      ctrlp
      editorconfig-vim
      gruvbox
      tabular
      vim-elixir
      vim-nix
      vim-graphql
      vim-markdown
    ];
  };
}