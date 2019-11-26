local skeleton = require 'nvim_lsp/skeleton'
local util = require 'nvim_lsp/util'
local lsp = vim.lsp

skeleton.vimls = {
  default_config = {
    cmd = {"vim-language-server", "--stdio"};
    filetypes = {"vim"};
    root_dir = vim.loop.os_homedir;
    log_level = lsp.protocol.MessageType.Warning;
    settings = {};
  };
  -- on_new_config = function(new_config) end;
  -- on_attach = function(client, bufnr) end;
  docs = {
    package_json = "https://raw.githubusercontent.com/iamcco/vim-language-server/master/package.json";
    description = [[
https://github.com/iamcco/vim-language-server

vim language server, lsp for viml
]];
    default_config = {
      root_dir = "vim's starting directory";
    };
  };
};
-- vim:et ts=2 sw=2
