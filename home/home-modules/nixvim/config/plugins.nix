{
  programs.nixvim.plugins = {
    lualine.enable = true;

    # [FIX] Explicitly enable web-devicons to fix the deprecation warning
    web-devicons.enable = true;

    # File Explorer
    neo-tree = {
      enable = true;
      # [FIX] 'closeIfLastWindow' was moved into 'settings' and renamed to snake_case
      settings = {
        close_if_last_window = true;
      };
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
