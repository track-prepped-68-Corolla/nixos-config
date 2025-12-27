{
  programs.nixvim.opts = {
    # Line numbers
    number = true;
    relativenumber = true;

    # Indentation
    expandtab = true;
    shiftwidth = 2;
    tabstop = 2;

    # Clipboard interaction
    clipboard = "unnamedplus";

    # Search behavior
    ignorecase = true;
    smartcase = true;

    # UI
    cursorline = true;
    termguicolors = true;
  };
}
