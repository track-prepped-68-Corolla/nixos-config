{
  programs.nixvim.plugins = {
    lualine.enable = true;

    # File Explorer
    neo-tree = {
      enable = true;
      closeIfLastWindow = true;
    };

    # Fuzzy Finder
    telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>fb" = "buffers";
      };
    };

    # Syntax Highlighting
    treesitter = {
      enable = true;
      settings = {
          highlight.enable = true;
          indent.enable = true;
      };
    };
  };
}
