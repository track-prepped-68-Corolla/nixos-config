{
  programs.nixvim = {
    globals.mapleader = " ";

    keymaps = [
      # Clear search highlights
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
      }
      # Save file
      {
        mode = "n";
        key = "<C-s>";
        action = "<cmd>w<CR>";
      }
      # Toggle NeoTree (File Explorer)
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
      }
    ];
  };
}
