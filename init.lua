-- Set leader key first
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1;

vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

if vim.fn.executable("fdfind") == 0 then
    vim.notify(
        "WARNING: 'fdfind' (fd-find) is not installed or not found in your PATH.\nFZF file search will not work until you install it.",
        vim.log.levels.WARN
    )
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
    { "wakatime/vim-wakatime", lazy = false },
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
        "ellisonleao/gruvbox.nvim",
        lazy = true,
        priority = 1000,
    },
    {
        "shaunsingh/moonlight.nvim",
        lazy = true,
        priority = 1000,
    },
    {
        "folke/tokyonight.nvim",
        lazy = true,
        priority = 1000,
    },
    {
        "shaunsingh/nord.nvim",
        lazy = true,
        priority = 1000,
    },
    {
        'notjedi/nvim-rooter.lua',
        config = function()
            require('nvim-rooter').setup()
        end
    },
    -- Add Telescope
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-ui-select.nvim'
        },
        config = function()
            require('telescope').setup({
                defaults = {
                    layout_strategy = 'horizontal',
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.55,
                            results_width = 0.8,
                        },
                        vertical = {
                            mirror = false,
                        },
                        width = 0.87,
                        height = 0.80,
                        preview_cutoff = 120,
                    },
                    sorting_strategy = "ascending",
                    winblend = 0,
                    border = {},
                    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
                    color_devicons = true,
                    use_less = true,
                    set_env = { ["COLORTERM"] = "truecolor" },
                    initial_mode = "normal",
                },
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({
                            -- Configure dropdown theme
                            winblend = 10,
                            width = 0.8,
                            previewer = false,
                            prompt_title = false,
                            initial_mode = "normal",
                        })
                    }
                }
            })
            -- Load the ui-select extension
            require("telescope").load_extension("ui-select")
        end
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                window = {
                    position = "right",
                    width = 40,
                    mappings = {
                        ["<"] = "none",
                        [">"] = "none",
                    },
                },
                filesystem = {
					filtered_items = {
						visible = false,
						hide_dotfiles = false,
						hide_gitignored = false,
						hide_by_name = {},
						hide_by_pattern = {
							"*.o",
						},
					},
                    hijack_netrw_behavior = "open_default",
                },
                event_handlers = {
                    {
                        event = "file_opened",
                        handler = function()
                            vim.cmd("Neotree close")
                        end
                    }
                },
            })
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    local argc = vim.fn.argc()
                    local arg0 = vim.fn.argv(0)
                    if argc == 0 or (argc == 1 and vim.loop.fs_stat(arg0 or "").type == "directory") then
                        vim.schedule(function()
                            require("neo-tree.command").execute({
                                action = "show",
                                source = "filesystem",
                                position = "right"
                            })
                            vim.schedule(function()
                                for _, win in ipairs(vim.api.nvim_list_wins()) do
                                    if vim.api.nvim_win_is_valid(win) then
                                        local buf = vim.api.nvim_win_get_buf(win)
                                        if vim.api.nvim_buf_is_valid(buf) then
                                            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
                                            if ft ~= "neo-tree" then
                                                pcall(vim.api.nvim_win_close, win, true)
                                            end
                                        end
                                    end
                                end
                            end)
                        end)
                    end
                end
            })
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" }
    },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/cmp-nvim-lsp" },
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
    },
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require("cmp")
            require("luasnip.loaders.from_vscode").lazy_load()
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                }),
                preselect = cmp.PreselectMode.Item,
                completion = {
                    completeopt = "menu,menuone,noinsert"
                },
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = {
                    "lua", "rust", "zig", "python", "go", "c", "cpp",
                    "html", "css", "javascript", "typescript", "tsx", "ocaml"
                },
                highlight = {
                    enable = true
                }
            }
        end
    },
    {
        "AlexvZyl/nordic.nvim",
        lazy = true,
        priority = 1000,
    },
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        config = function()
            require("typescript-tools").setup({})
        end,
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
}

require("lazy").setup(plugins, {})

-- Candle-grey inspired theme - monochrome with subtle accent
vim.cmd([[
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
    
    set background=dark
    let g:colors_name = "candle_inspired"
    
    " Core UI - Pure Black with grayscale
    hi Normal guifg=#bcbcbc guibg=#000000
    hi NormalFloat guifg=#bcbcbc guibg=#000000
    hi LineNr guifg=#4e4e4e guibg=#000000
    hi CursorLineNr guifg=#808080 guibg=#000000
    hi SignColumn guibg=#000000
    hi VertSplit guifg=#262626 guibg=#000000
    hi StatusLine guifg=#949494 guibg=#000000
    hi StatusLineNC guifg=#4e4e4e guibg=#000000
    hi Pmenu guifg=#bcbcbc guibg=#0a0a0a
    hi PmenuSel guifg=#ffffff guibg=#1c1c1c
    hi Visual guibg=#1c1c1c
    hi Search guifg=#000000 guibg=#808080
    hi CursorLine guibg=#0a0a0a
    
    " Syntax - Mostly monochrome with subtle accent (#af875f - muted gold/tan)
    hi Comment guifg=#6c6c6c gui=italic
    hi Constant guifg=#949494
    hi String guifg=#af875f
    hi Character guifg=#af875f
    hi Number guifg=#949494
    hi Boolean guifg=#949494
    hi Float guifg=#949494
    
    hi Identifier guifg=#bcbcbc
    hi Function guifg=#bcbcbc
    
    hi Statement guifg=#bcbcbc
    hi Conditional guifg=#bcbcbc
    hi Repeat guifg=#bcbcbc
    hi Label guifg=#bcbcbc
    hi Operator guifg=#808080
    hi Keyword guifg=#bcbcbc
    hi Exception guifg=#bcbcbc
    
    hi PreProc guifg=#bcbcbc
    hi Include guifg=#bcbcbc
    hi Define guifg=#bcbcbc
    hi Macro guifg=#bcbcbc
    hi PreCondit guifg=#bcbcbc
    
    hi Type guifg=#bcbcbc
    hi StorageClass guifg=#bcbcbc
    hi Structure guifg=#bcbcbc
    hi Typedef guifg=#bcbcbc
    
    hi Special guifg=#949494
    hi SpecialChar guifg=#949494
    hi Tag guifg=#bcbcbc
    hi Delimiter guifg=#6c6c6c
    hi SpecialComment guifg=#808080 gui=italic
    hi Debug guifg=#949494
    
    " Errors and warnings - subtle but visible
    hi Error guifg=#d75f5f guibg=NONE
    hi ErrorMsg guifg=#d75f5f guibg=NONE
    hi WarningMsg guifg=#d7875f guibg=NONE
    hi DiagnosticError guifg=#d75f5f
    hi DiagnosticWarn guifg=#d7875f
    hi DiagnosticInfo guifg=#808080
    hi DiagnosticHint guifg=#6c6c6c
    
    " LSP
    hi LspReferenceText guibg=#1c1c1c
    hi LspReferenceRead guibg=#1c1c1c
    hi LspReferenceWrite guibg=#1c1c1c
    
    " Treesitter - monochrome with string accent
    hi @variable guifg=#bcbcbc
    hi @variable.builtin guifg=#949494
    hi @function guifg=#bcbcbc
    hi @function.builtin guifg=#bcbcbc
    hi @keyword guifg=#bcbcbc
    hi @keyword.function guifg=#bcbcbc
    hi @keyword.import guifg=#bcbcbc
    hi @string guifg=#af875f
    hi @number guifg=#949494
    hi @boolean guifg=#949494
    hi @type guifg=#bcbcbc
    hi @type.builtin guifg=#949494
    hi @property guifg=#bcbcbc
    hi @field guifg=#bcbcbc
    hi @parameter guifg=#949494
    hi @namespace guifg=#bcbcbc
    hi @operator guifg=#808080
    hi @punctuation.bracket guifg=#6c6c6c
    hi @punctuation.delimiter guifg=#6c6c6c
    hi @comment guifg=#6c6c6c gui=italic
    hi @error guifg=#d75f5f
    
    " Telescope
    hi TelescopeBorder guifg=#3a3a3a
    hi TelescopePromptBorder guifg=#3a3a3a
    hi TelescopeResultsBorder guifg=#3a3a3a
    hi TelescopePreviewBorder guifg=#3a3a3a
    hi TelescopeSelection guibg=#1c1c1c
    hi TelescopeSelectionCaret guifg=#808080
    hi TelescopeMatching guifg=#ffffff
    
    " Neo-tree
    hi NeoTreeNormal guibg=#000000
    hi NeoTreeNormalNC guibg=#000000
    hi NeoTreeDirectoryIcon guifg=#808080
    hi NeoTreeDirectoryName guifg=#949494
    hi NeoTreeFileName guifg=#bcbcbc
    hi NeoTreeFileIcon guifg=#6c6c6c
    hi NeoTreeGitModified guifg=#d7875f
    hi NeoTreeGitAdded guifg=#87af87
    hi NeoTreeGitDeleted guifg=#d75f5f
    hi NeoTreeRootName guifg=#bcbcbc gui=underline
    hi NeoTreeIndentMarker guifg=#303030
    
    " Completion menu
    hi CmpItemAbbrMatch guifg=#ffffff
    hi CmpItemAbbrMatchFuzzy guifg=#bcbcbc
    hi CmpItemKind guifg=#808080
    hi CmpItemMenu guifg=#6c6c6c
]])

-- Configure lualine with candle-grey inspired theme
require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = {
            normal = {
                a = { fg = '#bcbcbc', bg = '#000000' },
                b = { fg = '#808080', bg = '#000000' },
                c = { fg = '#6c6c6c', bg = '#000000' },
            },
            insert = {
                a = { fg = '#bcbcbc', bg = '#000000' },
                b = { fg = '#808080', bg = '#000000' },
                c = { fg = '#6c6c6c', bg = '#000000' },
            },
            visual = {
                a = { fg = '#bcbcbc', bg = '#000000' },
                b = { fg = '#808080', bg = '#000000' },
                c = { fg = '#6c6c6c', bg = '#000000' },
            },
            replace = {
                a = { fg = '#bcbcbc', bg = '#000000' },
                b = { fg = '#808080', bg = '#000000' },
                c = { fg = '#6c6c6c', bg = '#000000' },
            },
            command = {
                a = { fg = '#bcbcbc', bg = '#000000' },
                b = { fg = '#808080', bg = '#000000' },
                c = { fg = '#6c6c6c', bg = '#000000' },
            },
            inactive = {
                a = { fg = '#4e4e4e', bg = '#000000' },
                b = { fg = '#4e4e4e', bg = '#000000' },
                c = { fg = '#4e4e4e', bg = '#000000' },
            },
        },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        always_show_tabline = true,
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "windows" },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
    inactive_sections = {
        lualine_c = { "filename" },
        lualine_x = { "location" },
    }
})

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 3
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.o.foldmethod = "indent"
vim.o.foldlevel = 99
vim.opt.foldenable = true
vim.keymap.set("n", ";", "za", { noremap = true, silent = true })

vim.filetype.add({
    extension = {
        tsx = "typescriptreact",
        jsx = "javascriptreact",
    },
})

require("mason").setup({ log_level = vim.log.levels.ERROR })
require("mason-lspconfig").setup({
    ensure_installed = {
		"lua_ls", "zls", "rust_analyzer",
		 "clangd", "gopls",
			"html", "cssls", "emmet_ls"
    },
})

local lsp = require("lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lsp.lua_ls.setup({ capabilities = capabilities })
lsp.zls.setup({ capabilities = capabilities })
lsp.clangd.setup({ capabilities = capabilities })
lsp.gopls.setup({ capabilities = capabilities })
lsp.html.setup({ capabilities = capabilities })
lsp.cssls.setup({ capabilities = capabilities })
lsp.emmet_ls.setup({
    capabilities = capabilities,
    filetypes = { "html", "css", "javascript", "javascriptreact", "typescriptreact" }
})

-- OCaml LSP setup with proper configuration
lsp.ocamllsp.setup({
    capabilities = capabilities,
    cmd = { "ocamllsp" },
    filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
    root_dir = lsp.util.root_pattern("*.opam", "esy.json", "package.json", "dune-project", "dune-workspace"),
    settings = {
        codelens = { enable = true },
        inlayHints = { enable = true },
    },
})

vim.diagnostic.config({
    virtual_text = {
        severity = { min = vim.diagnostic.severity.ERROR },
        spacing = 4,
        prefix = "",
        format = function(diagnostic)
            local severity_prefix = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN] = "",
                [vim.diagnostic.severity.INFO] = "",
                [vim.diagnostic.severity.HINT] = "",
            }
            return severity_prefix[diagnostic.severity] .. diagnostic.message
        end,
    },
    underline = true,
    update_in_insert = true,
    signs = false,
    float = {
        border = "rounded",
        source = "always",
    },
})

lsp.rust_analyzer.setup({
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            procMacro = { enable = true },
            diagnostics = { enable = true },
            cargo = { allFeatures = true },
        }
    },
    root_dir = require("lspconfig.util").root_pattern("Cargo.toml"),
})

vim.keymap.set("n", "<C-t>", ":Neotree toggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-a>", function()
    vim.lsp.buf.code_action()
end, { noremap = true, silent = true })
vim.keymap.set("n", "\\", ":Neotree toggle<CR>", { noremap = true, silent = true })

vim.env.RUST_BACKTRACE = "1"
vim.env.RA_LOG = "error"

-- =========================
-- Delete behavior
-- =========================
vim.keymap.set("v", "D", '"_D', { noremap = true })       -- Only D deletes to EOL without yankin

-- ==============================
-- Markdown Support
-- ==============================
vim.api.nvim_create_user_command('Md', function()
    if vim.bo.filetype == 'markdown' then
        vim.cmd('MarkdownPreview')
    else
        print('Not a markdown file')
    end
end, { desc = 'Open markdown preview' })

-- ==============
-- Telescope Pickers with Dropdown Theme
-- ==============

-- File picker using Telescope dropdown
vim.keymap.set('n', '<C-p>', function()
    require('telescope.builtin').find_files(require('telescope.themes').get_dropdown({
        winblend = 10,
        previewer = false,
        prompt_title = false,
        initial_mode = "normal",
    }))
end, { noremap = true, silent = true })

vim.keymap.set('n', '<Esc><CR>', function()
    require('telescope.builtin').find_files(require('telescope.themes').get_dropdown({
        winblend = 10,
        previewer = false,
        prompt_title = false,
        initial_mode = "normal",
    }))
end, { noremap = true, silent = true })

-- Buffer picker using Telescope dropdown
vim.keymap.set('n', '<Esc><Space>', function()
    require('telescope.builtin').buffers(require('telescope.themes').get_dropdown({
        winblend = 10,
        previewer = false,
        prompt_title = false,
        initial_mode = "normal",
        sort_mru = true,
        ignore_current_buffer = false,
    }))
end, { noremap = true, silent = true })

-- Function picker using Telescope dropdown with OCaml support
local function pick_functions()
    local filetype = vim.bo.filetype
    
    -- For OCaml, show variables (let bindings are reported as variables)
    if filetype == "ocaml" or filetype == "ocaml.interface" or filetype == "ocaml.menhir" then
        require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_dropdown({
            winblend = 10,
            previewer = false,
            prompt_title = false,
            initial_mode = "insert",
            symbols = { "variable" },
        }))
    else
        -- For other languages, filter to functions and methods
        require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_dropdown({
            winblend = 10,
            previewer = false,
            prompt_title = false,
            initial_mode = "normal",
            symbols = { "function", "method" },
        }))
    end
end

vim.keymap.set("n", "<Esc>;", pick_functions, { noremap = true, silent = true })

-- LSP References using Telescope dropdown
vim.keymap.set('n', 'gr', function()
    require('telescope.builtin').lsp_references(require('telescope.themes').get_dropdown({
        winblend = 10,
        previewer = false,
        prompt_title = false,
        initial_mode = "normal",
        include_current_line = true,
    }))
end, { noremap = true, silent = true })

-- LSP Definitions using Telescope dropdown
vim.keymap.set('n', 'gd', function()
    require('telescope.builtin').lsp_definitions(require('telescope.themes').get_dropdown({
        winblend = 10,
        previewer = false,
        prompt_title = false,
        initial_mode = "normal",
        jump_type = "never",
        reuse_win = true,
    }))
end, { noremap = true, silent = true })

-- esc + enter >> for all files
-- esc + space >> buffer
-- esc + ; >> functions
vim.opt.fillchars = { vert = '│' }

-- Suppress specific OCaml LSP messages
local original_notify = vim.notify
vim.notify = function(msg, log_level, opts)
    -- Suppress ocamlformat-rpc warning
    if msg and (msg:match("ocamlformat%-rpc") or msg:match("ocamlformat'")) then
        return
    end

    -- Otherwise, show normally
    original_notify(msg, log_level, opts)
end

-- Override LSP message handler to suppress ocamlformat warnings
vim.lsp.handlers["window/showMessage"] = function(err, result, ctx, config)
    -- Suppress ocamlformat-rpc messages
    if result and result.message and (result.message:match("ocamlformat%-rpc") or result.message:match("ocamlformat'")) then
        return
    end
    
    -- Use default handler for other messages
    vim.notify(result.message, result.type)
end

-- ==============================
-- Custom :Rename command
-- ==============================
vim.api.nvim_create_user_command("Rename", function()
    vim.lsp.buf.rename()
end, { desc = "LSP Rename symbol" })

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.cmd("highlight NeoTreeRootName gui=underline guifg=#bcbcbc")
  end,
})

-- :FIND command - interactive project-wide search
vim.api.nvim_create_user_command('FIND', function()
    require('telescope.builtin').live_grep(require('telescope.themes').get_dropdown({
        winblend = 10,
        previewer = false,
        prompt_title = false,
        initial_mode = "insert",
    }))
end, { desc = 'Search in project' })

-- :Find command - interactive search in current buffer
vim.api.nvim_create_user_command('Find', function()
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
        winblend = 10,
        previewer = false,
        prompt_title = false,
        initial_mode = "insert",
    }))
end, { desc = 'Search in current buffer' })
