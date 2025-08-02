-- Disable netrw entirely
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
    
-- Tabs & Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- Lazy.nvim Bootstrap
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

-- Plugins
local plugins = {
    {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
    },
    { "wakatime/vim-wakatime", lazy = false },
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
        "shaunsingh/nord.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme nord")
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    { "nvim-telescope/telescope.nvim", tag = '0.1.8', dependencies = { "nvim-lua/plenary.nvim" } },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-ui-select.nvim" },
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
                    position = "right", -- Show Neo-tree on the right
                    width = 40,
                },
                filesystem = {
                    hijack_netrw_behavior = "open_default",
                },
            })

            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    local argc = vim.fn.argc()
                    local arg0 = vim.fn.argv(0)

                    if argc == 0 or (argc == 1 and vim.loop.fs_stat(arg0 or "").type == "directory") then
                        vim.schedule(function()
                            -- Open Neo-tree
                            require("neo-tree.command").execute({
                                action = "show",
                                source = "filesystem",
                                position = "right"
                            })

                            -- Wait until next event loop tick to allow Neo-tree to render
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
                    "html", "css", "javascript", "typescript", "tsx"
                },
                highlight = {
                    enable = true
                }
            }
        end
    },
    {
        "AlexvZyl/nordic.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("nordic").load()
        end
    },
    {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        config = function()
            require("typescript-tools").setup({})
        end,
    },
    {
        "barrett-ruth/live-server.nvim",
        build = "npm install -g live-server",
        config = function()
            require("live-server").setup({})
        end
    },
}

-- Lazy
require("lazy").setup(plugins, {})

-- Theme + Lualine
require("catppuccin").setup()
vim.g.nord_disable_background = true
require("nord").set()

local skeme = require("lualine.themes.nord")
require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = skeme,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
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

-- General Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 3
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
vim.o.foldmethod = "indent"
vim.o.foldlevel = 99
vim.opt.foldenable = true
vim.keymap.set("n", ";", "za", { noremap = true, silent = true })

-- Filetypes for JSX/TSX
vim.filetype.add({
    extension = {
        tsx = "typescriptreact",
        jsx = "javascriptreact",
    },
})

-- LSP Setup
require("mason").setup({ log_level = vim.log.levels.ERROR })
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls", "zls", "rust_analyzer",
        "pyright", "clangd", "gopls",
        "html", "cssls", "emmet_ls"
    },
})

local lsp = require("lspconfig")
lsp.pyright.setup({})
lsp.lua_ls.setup({})
lsp.zls.setup({})
lsp.clangd.setup({})
lsp.gopls.setup({})
lsp.html.setup({})
lsp.cssls.setup({})
lsp.emmet_ls.setup({
    filetypes = { "html", "css", "javascript", "javascriptreact", "typescriptreact" }
})

-- Diagnostics
vim.diagnostic.config({
    virtual_text = {
        severity = { min = vim.diagnostic.severity.HINT },
        spacing = 4,
        prefix = "",
    },
    underline = true,
    update_in_insert = true,
    signs = true,
    float = {
        border = "rounded",
        source = "always",
    },
})

-- Rust Analyzer
lsp.rust_analyzer.setup({
    settings = {
        ["rust-analyzer"] = {
            procMacro = {
                enable = true
            },
            diagnostics = {
                enable = true,
            },
            cargo = {
                allFeatures = true,
            },
        }
    },
    root_dir = require("lspconfig.util").root_pattern("Cargo.toml"),
})

-- Telescope
local builtin = require("telescope.builtin")
require("telescope").setup({
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown({})
        }
    }
})
require("telescope").load_extension("fzf")
require("telescope").load_extension("ui-select")

-- Keymaps
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<C-t>", ":Neotree filesystem reveal right<CR>", {})
vim.keymap.set("n", "<C-x>", ":x!<CR>", {})
vim.keymap.set("n", "<C-a>", function()
    vim.lsp.buf.code_action()
end, {})
vim.keymap.set("n", "<Esc><Space>", function()
    require("telescope.builtin").find_files({ initial_mode = "normal" })
end, {})

-- Zig + Rust runner
vim.api.nvim_set_keymap("n", "rzig", ":w!<CR>:!zig run ", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "rust", ":w!<CR>:!cargo run<CR>", { noremap = true, silent = true })

-- Live Server
vim.keymap.set("n", "<leader>ls", function()
  require("live-server").start()
end, { desc = "Start Live Server" })

-- ENV
vim.env.RUST_BACKTRACE = "1"
vim.env.RA_LOG = "error"

