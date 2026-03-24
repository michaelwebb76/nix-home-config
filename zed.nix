# Zed editor settings

{
  config,
  lib,
  pkgs,
  ...
}:

let
  settingsJson = builtins.toJSON {
    agent = {
      tool_permissions = {
        tools = {
          delete_path = {
            default = "allow";
          };
          fetch = {
            always_allow = [
              { pattern = "^https?://github\\.com"; }
              { pattern = "^https?://api\\.github\\.com"; }
            ];
          };
          terminal = {
            default = "allow";
          };
        };
      };
      default_model = {
        provider = "anthropic";
        model = "claude-opus-4-6-latest";
      };
      model_parameters = [ ];
    };
    git_panel = {
      tree_view = true;
    };
    theme = "Catppuccin Mocha";
    auto_install_extensions = {
      csv = true;
      haskell = true;
      nix = true;
      ruby = true;
      terraform = true;
      toml = true;
    };
    autosave = "on_focus_change";
    buffer_font_family = "Fira Code";
    buffer_font_features = {
      ss09 = true;
    };
    buffer_font_size = 14;
    ensure_final_newline_on_save = true;
    file_scan_exclusions = [
      "**/.git"
      "**/.direnv"
      "**/dist*"
      "**/node_modules"
      "**/target"
    ];
    format_on_save = "on";
    git = {
      inline_blame = {
        enabled = true;
      };
    };
    languages = {
      HTML = {
        format_on_save = "off";
      };
      Haskell = {
        formatter = {
          external = {
            arguments = [
              "--stdin-input-file"
              "{buffer_path}"
            ];
            command = "ormolu";
          };
        };
        tab_size = 2;
      };
      JSON = {
        formatter = {
          external = {
            arguments = [
              "--stdin-filepath"
              "{buffer_path}"
            ];
            command = "prettier";
          };
        };
      };
      JavaScript = {
        formatter = {
          external = {
            arguments = [
              "--stdin-filepath"
              "{buffer_path}"
            ];
            command = "prettier";
          };
        };
      };
      Markdown = {
        wrap_guides = [ 100 ];
      };
      Nix = {
        formatter = {
          external = {
            command = "nixfmt";
          };
        };
        tab_size = 2;
      };
      Ruby = {
        tab_size = 2;
        wrap_guides = [ 100 ];
      };
      TypeScript = {
        formatter = {
          external = {
            arguments = [
              "--stdin-filepath"
              "{buffer_path}"
            ];
            command = "prettier";
          };
        };
      };
      YAML = {
        tab_size = 2;
      };
    };
    preview_tabs = {
      enabled = false;
    };
    remove_trailing_whitespace_on_save = true;
    show_whitespaces = "boundary";
    tab_size = 2;
    telemetry = {
      diagnostics = false;
      metrics = false;
    };
    terminal = {
      font_family = "Fira Mono";
      shell = {
        program = "zsh";
      };
    };
    ui_font_size = 15;
    wrap_guides = [ 80 ];
  };

  keymapJson = builtins.toJSON [
    {
      bindings = {
        "cmd-shift-d" = "editor::DuplicateLineDown";
        "cmd-y" = "editor::Redo";
      };
      context = "Editor";
    }
  ];
in
{
  home.file = {
    ".config/zed/settings.json" = {
      text = settingsJson;
      force = true;
    };
    ".config/zed/keymap.json" = {
      text = keymapJson;
      force = true;
    };
  };
}
