{
  programs.nixvim = {
    enable = true;
    colorschemes.gruvbox.enable = true;
    opts = {
      tabstop = 4;
      shiftwidth = 4;
      expandtab = false;
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers
    };
    globals.mapleader = " "; # Sets the leader key to comma
    plugins = {
      lightline.enable = true;
      which-key.enable = true;
      gitsigns.enable = true;
      fugitive.enable = true;
      cmp.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-nvim-lsp-document-symbol.enable = true;
      cmp-nvim-lsp-signature-help.enable = true;
      lsp = {
        enable = true;
        servers = {
          csharp-ls = {
            enable = true;
          };
          rust-analyzer = {
            enable = true;
          };
          fsautocomplete = {
            enable = true;
          };
          pyright = {
            enable = true;
          };
        };
      };
      telescope = {
        enable = true;
        highlightTheme = "gruvbox";
        keymaps = {
          "<C-p>" = {
            action = "git_files";
            options.desc = "Telescope Git Files";
          };
          "<leader>ss" = "live_grep";
        };
      };
    };
  };
}
