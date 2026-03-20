{ config, pkgs, ... }:

{
  programs.zed-editor = {
    enable = true;

    extensions = [
      "haskell"
      "nix"
      "ruby"
      "terraform"
      "toml"
      "csv"
    ];

    userSettings = {
      vim_mode = true;

      # Font settings (matching VSCode Fira Code with ss09 ligatures)
      buffer_font_family = "Fira Code";
      buffer_font_features = {
        ss09 = true;
      };
      buffer_font_size = 16;
      ui_font_size = 16;

      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark";
      };

      # Auto-save on focus change (matching VSCode files.autoSave: onFocusChange)
      autosave = "on_focus_change";

      # Format on save (matching VSCode editor.formatOnSave: true)
      format_on_save = "on";

      # Trailing whitespace & final newline (matching VSCode)
      remove_trailing_whitespace_on_save = true;
      ensure_final_newline_on_save = true;

      # Show whitespace at boundaries (matching VSCode editor.renderWhitespace: boundary)
      show_whitespaces = "boundary";

      # Rulers at 80 columns (matching VSCode editor.rulers: [80])
      wrap_guides = [ 80 ];

      tab_size = 2;

      # Load direnv via shell hook
      load_direnv = "shell_hook";

      # Disable preview tabs (matching VSCode workbench.editor.enablePreview: false)
      preview_tabs = {
        enabled = false;
      };

      # Terminal
      terminal = {
        shell = {
          program = "zsh";
        };
        font_family = "Fira Mono";
      };

      # File scan exclusions (matching VSCode files.exclude)
      file_scan_exclusions = [
        "**/.git"
        "**/.direnv"
        "**/dist*"
        "**/node_modules"
        "**/target"
      ];

      telemetry = {
        metrics = false;
      };

      language_models = {
        anthropic = {
          version = "1";
        };
      };

      features = {
        edit_prediction_provider = "none";
      };

      assistant = {
        default_model = {
          provider = "anthropic";
          model = "claude-sonnet-4-20250514";
        };
        version = "2";
      };

      git = {
        inline_blame = {
          enabled = true;
        };
      };

      # Language-specific overrides
      languages = {
        Ruby = {
          tab_size = 2;
          wrap_guides = [ 100 ];
        };
        Markdown = {
          wrap_guides = [ 100 ];
        };
        Haskell = {
          tab_size = 2;
          formatter = {
            external = {
              command = "ormolu";
              arguments = [
                "--stdin-input-file"
                "{buffer_path}"
              ];
            };
          };
        };
        Nix = {
          tab_size = 2;
          formatter = {
            external = {
              command = "nixfmt";
            };
          };
        };
        JavaScript = {
          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        TypeScript = {
          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        JSON = {
          formatter = {
            external = {
              command = "prettier";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
              ];
            };
          };
        };
        YAML = {
          tab_size = 2;
        };
        HTML = {
          format_on_save = "off";
        };
        Python = {
          language_servers = [
            "pyright"
            "ruff"
          ];
          formatter = {
            external = {
              command = "ruff";
              arguments = [
                "format"
                "-"
              ];
            };
          };
        };
      };
    };

    userKeymaps = [
      {
        context = "Editor";
        bindings = {
          # Redo with cmd-y (matching VSCode keybinding)
          "cmd-y" = "editor::Redo";
          # Duplicate line with cmd-shift-d (matching VSCode keybinding)
          "cmd-shift-d" = "editor::DuplicateLineDown";
        };
      }
    ];
  };
}
