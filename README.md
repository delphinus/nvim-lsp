# nvim-lsp

WIP Common configurations for Language Servers.

This repository aims to be a central location to store configurations for
Language Servers which leverage Neovim's built-in LSP client `vim.lsp` as the
client backbone. The `vim.lsp` implementation is made to be customizable and
greatly extensible, but most users just want to get up and going. This
plugin/library is for those people, although it still lets you customize
things as much as you want in addition to the defaults that this provides.

**NOTE**: Requires current Neovim master as of 2019-11-13

**CONTRIBUTIONS ARE WELCOME!**

There's a lot of language servers in the world, and not enough time.  See
[`lua/nvim_lsp/*.lua`](https://github.com/neovim/nvim-lsp/blob/master/lua/nvim_lsp/)
for examples and ask us questions in the [Neovim
Gitter](https://gitter.im/neovim/neovim) to help us complete configurations for
*all the LSPs!* Read `CONTRIBUTING.md` for some instructions. NOTE: don't
modify `README.md`; it is auto-generated.

If you don't know where to start, you can pick one that's not in progress or
implemented from [this excellent list compiled by the coc.nvim
contributors](https://github.com/neoclide/coc.nvim/wiki/Language-servers) or
[this other excellent list from the emacs lsp-mode
contributors](https://github.com/emacs-lsp/lsp-mode#supported-languages)
and create a new file under `lua/nvim_lsp/SERVER_NAME.lua`. We recommend
looking at `lua/nvim_lsp/texlab.lua` for the most extensive example, but all of
them are good references.

## Progress

Implemented language servers:
- [bashls](#bashls)
- [ccls](#ccls)
- [clangd](#clangd)
- [cssls](#cssls)
- [elmls](#elmls)
- [flow](#flow)
- [fortls](#fortls)
- [gopls](#gopls)
- [hie](#hie)
- [leanls](#leanls)
- [pyls](#pyls)
- [rls](#rls)
- [solargraph](#solargraph)
- [sumneko_lua](#sumneko_lua)
- [texlab](#texlab)
- [tsserver](#tsserver)

Planned servers to implement (by me, but contributions welcome anyway):
- [lua-language-server](https://github.com/sumneko/lua-language-server)
- [rust-analyzer](https://github.com/rust-analyzer/rust-analyzer)

In progress:
- ...

## Install

`Plug 'neovim/nvim-lsp'`

## Usage

Servers configurations can be set up with a "setup function." These are
functions to set up servers more easily with some server specific defaults and
more server specific things like commands or different diagnostics.

The "setup functions" are `call nvim_lsp#setup({name}, {config})` from vim and
`nvim_lsp[name].setup(config)` from Lua.

Servers may define extra functions on the `nvim_lsp.SERVER` table, e.g.
`nvim_lsp.texlab.buf_build({bufnr})`.

### Auto Installation

Many servers can be automatically installed with the `:LspInstall`
command. Detailed installation info can be found
with the `:LspInstallInfo` command, which optionally accepts a specific server name.

For example:
```vim
LspInstall elmls
silent LspInstall elmls " useful if you want to autoinstall in init.vim
LspInstallInfo
LspInstallInfo elmls
```

### Example

From vim:
```vim
call nvim_lsp#setup("texlab", {})
```

From Lua:
```lua
require 'nvim_lsp'.texlab.setup {
  name = "texlab_fancy";
  log_level = vim.lsp.protocol.MessageType.Log;
  settings = {
    latex = {
      build = {
        onSave = true;
      }
    }
  }
}

local nvim_lsp = require 'nvim_lsp'

-- Customize how to find the root_dir
nvim_lsp.gopls.setup {
  root_dir = nvim_lsp.util.root_pattern(".git");
}

-- Build the current buffer.
require 'nvim_lsp'.texlab.buf_build(0)
```

### Setup function details

The main setup signature will be:

```
nvim_lsp.SERVER.setup({config})

  {config} is the same as |vim.lsp.start_client()|, but with some
  additions and changes:

  {root_dir}
    May be required (depending on the server).
    `function(filename, bufnr)` which is called on new candidate buffers to
    attach to and returns either a root_dir or nil.

    If a root_dir is returned, then this file will also be attached. You
    can optionally use {filetype} to help pre-filter by filetype.

    If a root_dir is returned which is unique from any previously returned
    root_dir, a new server will be spawned with that root_dir.

    If nil is returned, the buffer is skipped.

    See |nvim_lsp.util.search_ancestors()| and the functions which use it:
    - |nvim_lsp.util.root_pattern(patterns...)| finds an ancestor which
    - contains one of the files in `patterns...`. This is equivalent
    to coc.nvim's "rootPatterns"
    - More specific utilities:
      - |nvim_lsp.util.find_git_root()|
      - |nvim_lsp.util.find_node_modules_root()|
      - |nvim_lsp.util.find_package_json_root()|

  {name}
    Defaults to the server's name.

  {filetypes}
    A set of filetypes to filter for consideration by {root_dir}.
    Can be left empty.
    A server may specify a default value.

  {log_level}
    controls the level of logs to show from build processes and other
    window/logMessage events. By default it is set to
    vim.lsp.protocol.MessageType.Warning instead of
    vim.lsp.protocol.MessageType.Log.

  {settings}
    This is a table, and the keys are case sensitive. This is for the
    `workspace/configuration` event responses.
    We also notify the server *once* on `initialize` with
    `workspace/didChangeConfiguration`.
    If you change the settings later on, you should send the notification
    yourself with `client.workspace_did_change_configuration({settings})`
    Example: `settings = { keyName = { subKey = 1 } }`

  {on_attach}
    `function(client)` will be executed with the current buffer as the
    one the {client} is being attaching to. This is different from
    |vim.lsp.start_client()|'s on_attach parameter, which passes the {bufnr} as
    the second parameter instead. This is useful for running buffer local
    commands.

  {on_new_config}
    `function(new_config)` will be executed after a new configuration has been
    created as a result of {root_dir} returning a unique value. You can use this
    as an opportunity to further modify the new_config or use it before it is
    sent to |vim.lsp.start_client()|.
```

# LSP Implementations

## bashls

https://github.com/mads-hartmann/bash-language-server

Language server for bash, written using tree sitter in typescript.

Can be installed in neovim with `:LspInstall bashls`

```lua
nvim_lsp.bashls.setup({config})
nvim_lsp#setup("bashls", {config})

  Default Values:
    cmd = { "bash-language-server", "start" }
    filetypes = { "sh" }
    log_level = 2
    root_dir = vim's starting directory
    settings = {}
```

## ccls

https://github.com/MaskRay/ccls/wiki

ccls relies on a [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) specified
as compile_commands.json or, for simpler projects, a compile_flags.txt.


```lua
nvim_lsp.ccls.setup({config})
nvim_lsp#setup("ccls", {config})

  Default Values:
    capabilities = default capabilities, with offsetEncoding utf-8
    cmd = { "ccls" }
    filetypes = { "c", "cpp", "objc", "objcpp" }
    log_level = 2
    on_init = function to handle changing offsetEncoding
    root_dir = root_pattern("compile_commands.json", "compile_flags.txt", ".git")
    settings = {}
```

## clangd

https://clang.llvm.org/extra/clangd/Installation.html

**NOTE:** Clang >= 9 is recommended! See [this issue for more](https://github.com/neovim/nvim-lsp/issues/23).

clangd relies on a [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) specified
as compile_commands.json or, for simpler projects, a compile_flags.txt.


```lua
nvim_lsp.clangd.setup({config})
nvim_lsp#setup("clangd", {config})

  Default Values:
    capabilities = default capabilities, with offsetEncoding utf-8
    cmd = { "clangd", "--background-index" }
    filetypes = { "c", "cpp", "objc", "objcpp" }
    log_level = 2
    on_init = function to handle changing offsetEncoding
    root_dir = root_pattern("compile_commands.json", "compile_flags.txt", ".git")
    settings = {}
```

## cssls

https://github.com/vscode-langservers/vscode-css-languageserver-bin

`css-languageserver` can be installed via `:LspInstall cssls` or by yourself with `npm`:
```sh
npm install -g vscode-css-languageserver-bin
```

Can be installed in neovim with `:LspInstall cssls`

```lua
nvim_lsp.cssls.setup({config})
nvim_lsp#setup("cssls", {config})

  Default Values:
    capabilities = default capabilities, with offsetEncoding utf-8
    cmd = { "css-languageserver", "--stdio" }
    filetypes = { "css", "scss", "less" }
    log_level = 2
    on_init = function to handle changing offsetEncoding
    root_dir = root_pattern("package.json")
    settings = {
      css = {
        validate = true
      },
      less = {
        validate = true
      },
      scss = {
        validate = true
      }
    }
```

## elmls

https://github.com/elm-tooling/elm-language-server#installation

If you don't want to use neovim to install it, then you can use:
```sh
npm install -g elm elm-test elm-format @elm-tooling/elm-language-server
```

Can be installed in neovim with `:LspInstall elmls`

```lua
nvim_lsp.elmls.setup({config})
nvim_lsp#setup("elmls", {config})

  Default Values:
    capabilities = default capabilities, with offsetEncoding utf-8
    cmd = { "elm-language-server" }
    filetypes = { "elm" }
    init_options = {
      elmAnalyseTrigger = "change",
      elmFormatPath = "elm-format",
      elmPath = "elm",
      elmTestPath = "elm-test"
    }
    log_level = 2
    on_init = function to handle changing offsetEncoding
    root_dir = root_pattern("elm.json")
    settings = {}
```

## flow

https://flow.org/
https://github.com/facebook/flow

See below for how to setup Flow itself.
https://flow.org/en/docs/install/

See below for lsp command options.

```sh
npm run flow lsp -- --help
```
    

```lua
nvim_lsp.flow.setup({config})
nvim_lsp#setup("flow", {config})

  Default Values:
    cmd = { "npm", "run", "flow", "lsp" }
    filetypes = { "javascript", "javascriptreact", "javascript.jsx" }
    log_level = 2
    root_dir = root_pattern(".flowconfig")
    settings = {}
```

## fortls

https://github.com/hansec/fortran-language-server

Fortran Language Server for the Language Server Protocol
    

```lua
nvim_lsp.fortls.setup({config})
nvim_lsp#setup("fortls", {config})

  Default Values:
    cmd = { "fortls" }
    filetypes = { "fortran" }
    log_level = 2
    root_dir = root_pattern(".fortls")
    settings = {
      nthreads = 1
    }
```

## gopls

https://github.com/golang/tools/tree/master/gopls

Google's lsp server for golang.


```lua
nvim_lsp.gopls.setup({config})
nvim_lsp#setup("gopls", {config})

  Default Values:
    cmd = { "gopls" }
    filetypes = { "go" }
    log_level = 2
    root_dir = root_pattern("go.mod", ".git")
    settings = {}
```

## hie

https://github.com/haskell/haskell-ide-engine

the following init_options are supported (see https://github.com/haskell/haskell-ide-engine#configuration):
```lua
init_options = {
  languageServerHaskell = {
    hlintOn = bool;
    maxNumberOfProblems = number;
    diagnosticsDebounceDuration = number;
    liquidOn = bool (default false);
    completionSnippetsOn = bool (default true);
    formatOnImportOn = bool (default true);
    formattingProvider = string (default "brittany", alternate "floskell");
  }
}
```
        
This server accepts configuration via the `settings` key.
<details><summary>Available settings:</summary>

- **`languageServerHaskell.completionSnippetsOn`**: `boolean`

  Default: `true`
  
  Show snippets with type information when using code completion

- **`languageServerHaskell.diagnosticsOnChange`**: `boolean`

  Default: `true`
  
  Compute diagnostics continuously as you type. Turn off to only generate diagnostics on file save.

- **`languageServerHaskell.enableHIE`**: `boolean`

  Default: `true`
  
  Enable/disable HIE (useful for multi-root workspaces).

- **`languageServerHaskell.formatOnImportOn`**: `boolean`

  Default: `true`
  
  When adding an import, use the formatter on the result

- **`languageServerHaskell.formattingProvider`**: `enum { "brittany", "floskell", "none" }`

  Default: `"brittany"`
  
  The tool to use for formatting requests.

- **`languageServerHaskell.hieExecutablePath`**: `string`

  Default: `""`
  
  Set the path to your hie executable, if it's not already on your $PATH. Works with ~, ${HOME} and ${workspaceFolder}.

- **`languageServerHaskell.hlintOn`**: `boolean`

  Default: `true`
  
  Get suggestions from hlint

- **`languageServerHaskell.liquidOn`**: `boolean`

  Get diagnostics from liquid haskell

- **`languageServerHaskell.logFile`**: `string`

  Default: `""`
  
  If set, redirects the logs to a file.

- **`languageServerHaskell.maxNumberOfProblems`**: `number`

  Default: `100`
  
  Controls the maximum number of problems produced by the server.

- **`languageServerHaskell.showTypeForSelection.command.location`**: `enum { "dropdown", "channel" }`

  Default: `"dropdown"`
  
  Determines where the type information for selected text will be shown when the `showType` command is triggered (distinct from automatically showing this information when hover is triggered).
  dropdown: in a dropdown
  channel: will be revealed in an output channel

- **`languageServerHaskell.showTypeForSelection.onHover`**: `boolean`

  Default: `true`
  
  If true, when an expression is selected, the hover tooltip will attempt to display the type of the entire expression - rather than just the term under the cursor.

- **`languageServerHaskell.trace.server`**: `enum { "off", "messages", "verbose" }`

  Default: `"off"`
  
  Traces the communication between VSCode and the languageServerHaskell service.

- **`languageServerHaskell.useCustomHieWrapper`**: `boolean`

  Use your own custom wrapper for hie (remember to specify the path!). This will take precedence over useHieWrapper and hieExecutablePath.

- **`languageServerHaskell.useCustomHieWrapperPath`**: `string`

  Default: `""`
  
  Specify the full path to your own custom hie wrapper (e.g. ${HOME}/.hie-wrapper.sh). Works with ~, ${HOME} and ${workspaceFolder}.

</details>

```lua
nvim_lsp.hie.setup({config})
nvim_lsp#setup("hie", {config})

  Default Values:
    cmd = { "hie-wrapper" }
    filetypes = { "haskell" }
    log_level = 2
    root_dir = root_pattern("stack.yaml", "package.yaml", ".git")
    settings = {}
```

## leanls

    https://github.com/leanprover/lean-client-js/tree/master/lean-language-server

    Lean language server.
    

```lua
nvim_lsp.leanls.setup({config})
nvim_lsp#setup("leanls", {config})

  Default Values:
    cmd = { "lean-language-server", "--stdio" }
    filetypes = { "lean" }
    log_level = 2
    root_dir = util.root_pattern(".git")
    settings = {}
```

## pyls

https://github.com/palantir/python-language-server

`python-language-server`, a language server for Python.
    
This server accepts configuration via the `settings` key.
<details><summary>Available settings:</summary>

- **`pyls.configurationSources`**: `array`

  Default: `{ "pycodestyle" }`
  
  Array items: `{enum = { "pycodestyle", "pyflakes" },type = "string"}`
  
  List of configuration sources to use.

- **`pyls.executable`**: `string`

  Default: `"pyls"`
  
  Language server executable

- **`pyls.plugins.jedi.environment`**: `string`

  Default: `vim.NIL`
  
  Define environment for jedi.Script and Jedi.names.

- **`pyls.plugins.jedi.extra_paths`**: `array`

  Default: `{}`
  
  Define extra paths for jedi.Script.

- **`pyls.plugins.jedi_completion.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.plugins.jedi_completion.include_params`**: `boolean`

  Default: `true`
  
  Auto-completes methods and classes with tabstops for each parameter.

- **`pyls.plugins.jedi_definition.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.plugins.jedi_definition.follow_builtin_imports`**: `boolean`

  Default: `true`
  
  If follow_imports is True will decide if it follow builtin imports.

- **`pyls.plugins.jedi_definition.follow_imports`**: `boolean`

  Default: `true`
  
  The goto call will follow imports.

- **`pyls.plugins.jedi_hover.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.plugins.jedi_references.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.plugins.jedi_signature_help.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.plugins.jedi_symbols.all_scopes`**: `boolean`

  Default: `true`
  
  If True lists the names of all scopes instead of only the module namespace.

- **`pyls.plugins.jedi_symbols.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.plugins.mccabe.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.plugins.mccabe.threshold`**: `number`

  Default: `15`
  
  The minimum threshold that triggers warnings about cyclomatic complexity.

- **`pyls.plugins.preload.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.plugins.preload.modules`**: `array`

  Default: `vim.NIL`
  
  Array items: `{type = "string"}`
  
  List of modules to import on startup

- **`pyls.plugins.pycodestyle.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.plugins.pycodestyle.exclude`**: `array`

  Default: `vim.NIL`
  
  Array items: `{type = "string"}`
  
  Exclude files or directories which match these patterns.

- **`pyls.plugins.pycodestyle.filename`**: `array`

  Default: `vim.NIL`
  
  Array items: `{type = "string"}`
  
  When parsing directories, only check filenames matching these patterns.

- **`pyls.plugins.pycodestyle.hangClosing`**: `boolean`

  Default: `vim.NIL`
  
  Hang closing bracket instead of matching indentation of opening bracket's line.

- **`pyls.plugins.pycodestyle.ignore`**: `array`

  Default: `vim.NIL`
  
  Array items: `{type = "string"}`
  
  Ignore errors and warnings

- **`pyls.plugins.pycodestyle.maxLineLength`**: `number`

  Default: `vim.NIL`
  
  Set maximum allowed line length.

- **`pyls.plugins.pycodestyle.select`**: `array`

  Default: `vim.NIL`
  
  Array items: `{type = "string"}`
  
  Select errors and warnings

- **`pyls.plugins.pydocstyle.addIgnore`**: `array`

  Default: `vim.NIL`
  
  Array items: `{type = "string"}`
  
  Ignore errors and warnings in addition to the specified convention.

- **`pyls.plugins.pydocstyle.addSelect`**: `array`

  Default: `vim.NIL`
  
  Array items: `{type = "string"}`
  
  Select errors and warnings in addition to the specified convention.

- **`pyls.plugins.pydocstyle.convention`**: `enum { "pep257", "numpy" }`

  Default: `vim.NIL`
  
  Choose the basic list of checked errors by specifying an existing convention.

- **`pyls.plugins.pydocstyle.enabled`**: `boolean`

  Enable or disable the plugin.

- **`pyls.plugins.pydocstyle.ignore`**: `array`

  Default: `vim.NIL`
  
  Array items: `{type = "string"}`
  
  Ignore errors and warnings

- **`pyls.plugins.pydocstyle.match`**: `string`

  Default: `"(?!test_).*\\.py"`
  
  Check only files that exactly match the given regular expression; default is to match files that don't start with 'test_' but end with '.py'.

- **`pyls.plugins.pydocstyle.matchDir`**: `string`

  Default: `"[^\\.].*"`
  
  Search only dirs that exactly match the given regular expression; default is to match dirs which do not begin with a dot.

- **`pyls.plugins.pydocstyle.select`**: `array`

  Default: `vim.NIL`
  
  Array items: `{type = "string"}`
  
  Select errors and warnings

- **`pyls.plugins.pyflakes.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.plugins.pylint.args`**: `array`

  Default: `vim.NIL`
  
  Array items: `{type = "string"}`
  
  Arguments to pass to pylint.

- **`pyls.plugins.pylint.enabled`**: `boolean`

  Enable or disable the plugin.

- **`pyls.plugins.rope_completion.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.plugins.yapf.enabled`**: `boolean`

  Default: `true`
  
  Enable or disable the plugin.

- **`pyls.rope.extensionModules`**: `string`

  Default: `vim.NIL`
  
  Builtin and c-extension modules that are allowed to be imported and inspected by rope.

- **`pyls.rope.ropeFolder`**: `array`

  Default: `vim.NIL`
  
  Array items: `{type = "string"}`
  
  The name of the folder in which rope stores project configurations and data.  Pass `null` for not using such a folder at all.

</details>

```lua
nvim_lsp.pyls.setup({config})
nvim_lsp#setup("pyls", {config})

  Default Values:
    cmd = { "pyls" }
    filetypes = { "python" }
    log_level = 2
    root_dir = vim's starting directory
    settings = {}
```

## rls

https://github.com/rust-lang/rls

rls, a language server for Rust

Refer to the following for how to setup rls itself.
https://github.com/rust-lang/rls#setup

See below for rls specific settings.
https://github.com/rust-lang/rls#configuration

If you want to use rls for a particular build, eg nightly, set cmd as follows:

```lua
cmd = {"rustup", "run", "nightly", "rls"}
```
    

```lua
nvim_lsp.rls.setup({config})
nvim_lsp#setup("rls", {config})

  Default Values:
    cmd = { "rls" }
    filetypes = { "rust" }
    log_level = 2
    root_dir = root_pattern("Cargo.toml")
    settings = {}
```

## solargraph

https://solargraph.org/

solargraph, a language server for Ruby

You can install solargraph via gem install.

```sh
gem install solargraph
```
    
This server accepts configuration via the `settings` key.
<details><summary>Available settings:</summary>

- **`solargraph.autoformat`**: `enum { true, false }`

  Enable automatic formatting while typing (WARNING: experimental)

- **`solargraph.bundlerPath`**: `string`

  Default: `"bundle"`
  
  Path to the bundle executable, defaults to 'bundle'

- **`solargraph.checkGemVersion`**: `enum { true, false }`

  Default: `true`
  
  Automatically check if a new version of the Solargraph gem is available.

- **`solargraph.commandPath`**: `string`

  Default: `"solargraph"`
  
  Path to the solargraph command.  Set this to an absolute path to select from multiple installed Ruby versions.

- **`solargraph.completion`**: `enum { true, false }`

  Default: `true`
  
  Enable completion

- **`solargraph.definitions`**: `enum { true, false }`

  Default: `true`
  
  Enable definitions (go to, etc.)

- **`solargraph.diagnostics`**: `enum { true, false }`

  Enable diagnostics

- **`solargraph.externalServer`**: `object`

  Default: `{host = "localhost",port = 7658}`
  
  The host and port to use for external transports. (Ignored for stdio and socket transports.)

- **`solargraph.folding`**: `boolean`

  Default: `true`
  
  Enable folding ranges

- **`solargraph.formatting`**: `enum { true, false }`

  Enable document formatting

- **`solargraph.hover`**: `enum { true, false }`

  Default: `true`
  
  Enable hover

- **`solargraph.logLevel`**: `enum { "warn", "info", "debug" }`

  Default: `"warn"`
  
  Level of debug info to log. `warn` is least and `debug` is most.

- **`solargraph.references`**: `enum { true, false }`

  Default: `true`
  
  Enable finding references

- **`solargraph.rename`**: `enum { true, false }`

  Default: `true`
  
  Enable symbol renaming

- **`solargraph.symbols`**: `enum { true, false }`

  Default: `true`
  
  Enable symbols

- **`solargraph.transport`**: `enum { "socket", "stdio", "external" }`

  Default: `"socket"`
  
  The type of transport to use.

- **`solargraph.useBundler`**: `boolean`

  Use `bundle exec` to run solargraph. (If this is true, the solargraph.commandPath setting is ignored.)

</details>

```lua
nvim_lsp.solargraph.setup({config})
nvim_lsp#setup("solargraph", {config})

  Default Values:
    cmd = { "solargraph", "stdio" }
    filetypes = { "ruby" }
    log_level = 2
    root_dir = root_pattern("Gemfile", ".git")
    settings = {}
```

## sumneko_lua

https://github.com/sumneko/lua-language-server

Lua language server. **By default, this doesn't have a `cmd` set.** This is
because it doesn't provide a global binary. We provide an installer for Linux
using `:LspInstall`.  If you wish to install it yourself, [here is a
guide](https://github.com/sumneko/lua-language-server/wiki/Build-and-Run).

Can be installed in neovim with `:LspInstall sumneko_lua`
This server accepts configuration via the `settings` key.
<details><summary>Available settings:</summary>

- **`Lua.completion.callSnippet`**: `enum { "Disable", "Both", "Replace" }`

  Default: `"Disable"`

- **`Lua.completion.enable`**: `boolean`

  Default: `true`

- **`Lua.completion.keywordSnippet`**: `enum { "Disable", "Both", "Replace" }`

  Default: `"Replace"`

- **`Lua.diagnostics.disable`**: `array`

  Array items: `{type = "string"}`

- **`Lua.diagnostics.enable`**: `boolean`

  Default: `true`

- **`Lua.diagnostics.globals`**: `array`

  Array items: `{type = "string"}`

- **`Lua.diagnostics.severity`**: `object`

  

- **`Lua.runtime.path`**: `array`

  Default: `{ "?.lua", "?/init.lua", "?/?.lua" }`
  
  Array items: `{type = "string"}`

- **`Lua.runtime.version`**: `enum { "Lua 5.1", "Lua 5.2", "Lua 5.3", "Lua 5.4", "LuaJIT" }`

  Default: `"Lua 5.3"`

- **`Lua.workspace.ignoreDir`**: `array`

  Default: `{ ".vscode" }`
  
  Array items: `{type = "string"}`

- **`Lua.workspace.ignoreSubmodules`**: `boolean`

  Default: `true`

- **`Lua.workspace.library`**: `object`

  

- **`Lua.workspace.maxPreload`**: `integer`

  Default: `300`

- **`Lua.workspace.preloadFileSize`**: `integer`

  Default: `100`

- **`Lua.workspace.useGitIgnore`**: `boolean`

  Default: `true`

- **`Lua.zzzzzz.cat`**: `boolean`

  

</details>

```lua
nvim_lsp.sumneko_lua.setup({config})
nvim_lsp#setup("sumneko_lua", {config})

  Default Values:
    filetypes = { "lua" }
    log_level = 2
    root_dir = root_pattern(".git") or os_homedir
    settings = {}
```

## texlab

https://texlab.netlify.com/

A completion engine built from scratch for (La)TeX.

See https://texlab.netlify.com/docs/reference/configuration for configuration options.


```lua
nvim_lsp.texlab.setup({config})
nvim_lsp#setup("texlab", {config})

  Commands:
  - TexlabBuild: Build the current buffer
  
  Default Values:
    cmd = { "texlab" }
    filetypes = { "tex", "bib" }
    log_level = 2
    root_dir = vim's starting directory
    settings = {
      bibtex = {
        formatting = {
          lineLength = 120
        }
      },
      latex = {
        build = {
          args = { "-pdf", "-interaction=nonstopmode", "-synctex=1" },
          executable = "latexmk",
          onSave = false
        },
        forwardSearch = {
          args = {},
          onSave = false
        },
        lint = {
          onChange = false
        }
      }
    }
```

## tsserver

https://github.com/theia-ide/typescript-language-server

`typescript-language-server` can be installed via `:LspInstall tsserver` or by yourself with `npm`: 
```sh
npm install -g typescript-language-server
```

Can be installed in neovim with `:LspInstall tsserver`

```lua
nvim_lsp.tsserver.setup({config})
nvim_lsp#setup("tsserver", {config})

  Default Values:
    capabilities = default capabilities, with offsetEncoding utf-8
    cmd = { "typescript-language-server", "--stdio" }
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" }
    log_level = 2
    on_init = function to handle changing offsetEncoding
    root_dir = root_pattern("package.json")
    settings = {}
```

