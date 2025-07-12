{...}: {
  vim = {
    options.shiftwidth = 2;

    telescope.enable = true;
    autocomplete.nvim-cmp.enable = true;
    binds.whichKey.enable = true;

    visuals = {
      nvim-scrollbar.enable = false;
      nvim-web-devicons.enable = true;
      nvim-cursorline.enable = true;
      cinnamon-nvim.enable = true;
      fidget-nvim.enable = true;

      highlight-undo.enable = true;
      indent-blankline.enable = true;

      # Fun
      cellular-automaton.enable = false;
    };

    tabline = {
      nvimBufferline.enable = true;
    };

    treesitter.context.enable = true;

    git = {
      enable = true;
      gitsigns.enable = true;
      gitsigns.codeActions.enable = false; # throws an annoying debug message
    };

    comments = {
      comment-nvim.enable = true;
    };

    statusline = {
      lualine = {
        enable = true;
        theme = "tokyonight";
      };
    };

    theme = {
      enable = true;
      name = "tokyonight";
      style = "night";
      transparent = false;
    };

    autopairs.nvim-autopairs.enable = true;

    assistant = {
      copilot = {
        enable = true;
        cmp.enable = true;
        mappings = {
          suggestion.accept = "<Tab>";
        };
      };
    };

    languages = {
      enableLSP = true;
      enableTreesitter = true;
      enableFormat = true;
      nix = {
        enable = true;
        lsp.server = "nixd";
        format.enable = true;
      };
      # ts.enable = true;
      # rust.enable = true;
    };
  };
}
