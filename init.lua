-- Set leader key first
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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
        "sainnhe/sonokai",
        lazy = false,
        priority = 1000,
        config = function()
            vim.g.sonokai_style = 'espresso'
            -- Enable better performance
            vim.g.sonokai_better_performance = 1
            -- Make it more transparent (optional)
            vim.g.sonokai_transparent_background = 0
            -- Disable italic comments if desired
            vim.g.sonokai_disable_italic_comment = 0
            -- Enable cursor line highlighting
            vim.g.sonokai_cursor_line_style = 'bold'
            
            vim.o.background = "dark"
            vim.cmd("colorscheme sonokai")
        end,
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
		'ibhagwan/fzf-lua',
		config = function()
            require'fzf-lua'.setup{
                winopts = {
                    split = "belowright 7new",
                    preview = { hidden = true }
                },

				files = {
					file_icons = false,
					git_icons = true,
					_fzf_nth_devicons = true,
				},
                fzf_opts = {
                    ["--layout"] = "default",
                    ["--no-info"] = "",
                },
				buffers = {
					file_icons = false,
					git_icons = false,
					always_show_tabline = false,
                    ignore_current_buffer = false,
                    sort_mru = true,
                    show_all_buffers = true,
                    cwd_only = false,
				}
            }
            vim.keymap.set('n', '<C-p>', function()
                require('fzf-lua').files()
            end, { noremap = true, silent = true })
            vim.keymap.set('n', '<Esc><CR>', function()
                require('fzf-lua').files()
            end, { noremap = true, silent = true })
            vim.keymap.set('n', '<Esc><Space>', function()
                require('fzf-lua').buffers()
            end, { noremap = true, silent = true })
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
                },
                filesystem = {
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

-- Configure lualine with sonokai theme
require("lualine").setup({
    options = {
        icons_enabled = true,
        theme = "sonokai",
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

lsp.rust_analyzer.setup({
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
-- Function find
-- ==============

-- Function picker using fzf-lua + LSP
local function pick_functions()
  local params = { textDocument = vim.lsp.util.make_text_document_params() }
  vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(_, result, _, _)
    if not result then return end

    local entries = {}
    for _, symbol in ipairs(result) do
      local kind = symbol.kind
      if kind == 12 or kind == 6 then -- Function = 12, Method = 6
        local range = symbol.range.start
        table.insert(entries, {
          text = symbol.name,
          lnum = range.line + 1,
          col = range.character + 1,
          filename = vim.api.nvim_buf_get_name(0),
        })
      end
    end

    if vim.tbl_isempty(entries) then
      print("No functions found")
      return
    end

    require("fzf-lua").fzf_exec(
      vim.tbl_map(function(item)
        return string.format("%s:%d:%d", item.text, item.lnum, item.col)
      end, entries),
      {
        prompt = "Functions> ",
        actions = {
          ["default"] = function(selected)
            local name, lnum, col = selected[1]:match("^(.*):(%d+):(%d+)$")
            vim.api.nvim_win_set_cursor(0, { tonumber(lnum), tonumber(col) - 1 })
          end,
        },
      }
    )
  end)
end

-- Map <Esc>; to function picker
vim.keymap.set("n", "<Esc>;", pick_functions, { noremap = true, silent = true })

