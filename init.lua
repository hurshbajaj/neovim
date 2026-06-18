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
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				rust = { "rustfmt" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},
	{
		"folke/noice.nvim",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				cmdline = {
					view = "cmdline_popup",
				},
				messages = {
					enabled = true,
				},
				notify = {
					view = "mini",
				},
				views = {
					mini = {
						win_options = { winblend = 0 },
						position = { row = -2, col = "97%" },
						border = { style = "none" },
					},
				},
				routes = {
					{ filter = { event = "notify" },                  view = "mini" },
					{ filter = { event = "msg_show", kind = "" },     view = "mini" },
					{ filter = { event = "msg_show", kind = "emsg" }, view = "mini" },
					{ filter = { event = "msg_show", kind = "wmsg" }, view = "mini" },
					{ filter = { error = true },                      view = "mini" },
					{ filter = { warning = true },                    view = "mini" },
				},
			})
		end,
	},
	{ "wakatime/vim-wakatime",            lazy = false },
	{
		"metalelf0/base16-black-metal-scheme",
		lazy = false,
		priority = 1000,
	},
	{
		'notjedi/nvim-rooter.lua',
		config = function()
			require('nvim-rooter').setup()
		end
	},
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
							winblend = 10,
							previewer = false,
							prompt_title = false,
							initial_mode = "normal",
							layout_config = {
								width = 0.4,
								height = 0.4,
							},
						})
					}
				}
			})
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

			local kind_icons = {
				Text = "󰉿 ",
				Method = "󰆧 ",
				Function = "󰊕 ",
				Constructor = " ",
				Field = "󰜢 ",
				Variable = "󰀫 ",
				Class = "󰠱 ",
				Interface = " ",
				Module = " ",
				Property = "󰜢 ",
				Unit = "󰑭 ",
				Value = "󰎠 ",
				Enum = " ",
				Keyword = "󰌋 ",
				Snippet = " ",
				Color = "󰏘 ",
				File = "󰈙 ",
				Reference = "󰈇 ",
				Folder = "󰉋 ",
				EnumMember = " ",
				Constant = "󰏿 ",
				Struct = "󰙅 ",
				Event = " ",
				Operator = "󰆕 ",
				TypeParameter = "󰊄 ",
			}

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = {
						border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
						-- We link CmpMenu to Pmenu, and FloatBorder to CmpMenuBorder
						winhighlight = "Normal:Pmenu,FloatBorder:CmpMenuBorder,CursorLine:PmenuSel,Search:None",
					},
					documentation = cmp.config.disable,
				},
				formatting = {
					fields = { "kind", "abbr" },
					format = function(entry, vim_item)
						vim_item.kind = kind_icons[vim_item.kind] or ""
						return vim_item
					end,
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
				-- This explicitly forces the first option to be selected immediately
				preselect = cmp.PreselectMode.Item,
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup {
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

vim.cmd.colorscheme("base16-black-metal")

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "Bathory",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		always_show_tabline = true,
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },

		-- CHANGE THIS LINE RIGHT HERE:
		lualine_c = {
			"windows",
			{
				require("noice").api.status.mode.get,
				cond = require("noice").api.status.mode.has,
				color = { fg = "#ee7967" }, -- Perfectly matches your config's custom orange accent color!
			}
		},

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
vim.opt.signcolumn = "no"
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

vim.keymap.set("v", "D", '"_D', { noremap = true })

vim.api.nvim_create_user_command('Md', function()
	if vim.bo.filetype == 'markdown' then
		vim.cmd('MarkdownPreview')
	else
		print('Not a markdown file')
	end
end, { desc = 'Open markdown preview' })

vim.keymap.set('n', '<C-p>', function()
	require('telescope.builtin').find_files(require('telescope.themes').get_dropdown({
		winblend = 10,
		previewer = false,
		prompt_title = false,
		initial_mode = "normal",
		layout_config = {
			width = 0.4,
			height = 0.4,
		},
	}))
end, { noremap = true, silent = true })

vim.keymap.set('n', '<Esc><CR>', function()
	require('telescope.builtin').find_files(require('telescope.themes').get_dropdown({
		winblend = 10,
		previewer = false,
		prompt_title = false,
		initial_mode = "normal",
		layout_config = {
			width = 0.4,
			height = 0.4,
		},
	}))
end, { noremap = true, silent = true })

vim.keymap.set('n', '<Esc><Space>', function()
	require('telescope.builtin').buffers(require('telescope.themes').get_dropdown({
		winblend = 10,
		previewer = false,
		prompt_title = false,
		initial_mode = "normal",
		sort_mru = true,
		ignore_current_buffer = false,
		layout_config = {
			width = 0.4,
			height = 0.4,
		},
	}))
end, { noremap = true, silent = true })

local function pick_functions()
	local filetype = vim.bo.filetype

	if filetype == "ocaml" or filetype == "ocaml.interface" or filetype == "ocaml.menhir" then
		require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_dropdown({
			winblend = 10,
			previewer = false,
			prompt_title = false,
			initial_mode = "insert",
			symbols = { "variable" },
			layout_config = {
				width = 0.4,
				height = 0.4,
			},
		}))
	else
		require('telescope.builtin').lsp_document_symbols(require('telescope.themes').get_dropdown({
			winblend = 10,
			previewer = false,
			prompt_title = false,
			initial_mode = "normal",
			symbols = { "function", "method" },
			layout_config = {
				width = 0.4,
				height = 0.4,
			},
		}))
	end
end

vim.keymap.set("n", "<Esc>;", pick_functions, { noremap = true, silent = true })

vim.keymap.set('n', 'gr', function()
	require('telescope.builtin').lsp_references(require('telescope.themes').get_dropdown({
		winblend = 10,
		previewer = false,
		prompt_title = false,
		initial_mode = "normal",
		include_current_line = true,
		layout_config = {
			width = 0.4,
			height = 0.4,
		},
	}))
end, { noremap = true, silent = true })

vim.keymap.set('n', 'gd', function()
	require('telescope.builtin').lsp_definitions(require('telescope.themes').get_dropdown({
		winblend = 10,
		previewer = false,
		prompt_title = false,
		initial_mode = "normal",
		jump_type = "never",
		reuse_win = true,
		layout_config = {
			width = 0.4,
			height = 0.4,
		},
	}))
end, { noremap = true, silent = true })

vim.opt.fillchars = { vert = '│' }

local original_notify = vim.notify
vim.notify = function(msg, log_level, opts)
	if msg and (msg:match("ocamlformat%-rpc") or msg:match("ocamlformat'")) then
		return
	end

	original_notify(msg, log_level, opts)
end

vim.lsp.handlers["window/showMessage"] = function(err, result, ctx, config)
	if result and result.message and (result.message:match("ocamlformat%-rpc") or result.message:match("ocamlformat'")) then
		return
	end

	vim.notify(result.message, result.type)
end

vim.api.nvim_create_user_command("Rename", function()
	vim.lsp.buf.rename()
end, { desc = "LSP Rename symbol" })

vim.api.nvim_create_user_command('FIND', function()
	require('telescope.builtin').live_grep(require('telescope.themes').get_dropdown({
		winblend = 10,
		previewer = false,
		prompt_title = false,
		initial_mode = "insert",
		layout_config = {
			width = 0.4,
			height = 0.45,
		},
	}))
end, { desc = 'Search in project' })

vim.api.nvim_create_user_command('Find', function()
	require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
		winblend = 10,
		previewer = false,
		prompt_title = false,
		initial_mode = "insert",
		layout_config = {
			width = 0.4,
			height = 0.45,
		},
	}))
end, { desc = 'Search in current buffer' })

vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function(args)
		local bytes = vim.fn.getfsize(args.file)
		if bytes >= 0 then
			vim.notify(
				string.format("%s written (%d bytes)", vim.fn.fnamemodify(args.file, ":t"), bytes),
				vim.log.levels.INFO
			)
		else
			vim.notify(
				string.format("%s written", vim.fn.fnamemodify(args.file, ":t")),
				vim.log.levels.INFO
			)
		end
	end,
})

vim.keymap.set("n", "<CR>", function()
	require("notify").dismiss({ silent = true, pending = true })
end, { noremap = true, silent = true })
vim.opt.statuscolumn = "  %s%=%{v:relnum?v:relnum:v:lnum} %#Normal#  "
vim.opt.relativenumber = true

vim.opt.statuscolumn = "  %s%=%{v:relnum?v:relnum:v:lnum} %#Normal#  "

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	callback = function()
		if vim.bo.filetype == "neo-tree" then
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
			vim.opt_local.statuscolumn = ""
		end
	end,
})

vim.keymap.set("n", "e", function()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
	if #diagnostics == 0 then return end

	local lines = {}
	for _, d in ipairs(diagnostics) do
		local prefix = ({
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN]  = " ",
			[vim.diagnostic.severity.INFO]  = " ",
			[vim.diagnostic.severity.HINT]  = " ",
		})[d.severity] or ""

		local raw_lines = {}
		for part in (d.message .. "\n"):gmatch("([^\n]*)\n") do
			table.insert(raw_lines, part)
		end

		local width = 60
		for i, part in ipairs(raw_lines) do
			local msg = (i == 1 and prefix or "  ") .. part
			while #msg > width do
				local break_at = msg:sub(1, width):match(".*()%s") or width
				table.insert(lines, msg:sub(1, break_at - 1))
				msg = "  " .. msg:sub(break_at + 1)
			end
			table.insert(lines, msg)
		end
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

	local max_width = 0
	for _, l in ipairs(lines) do
		max_width = math.max(max_width, #l)
	end
	max_width = math.min(max_width, 65)

	local win = vim.api.nvim_open_win(buf, false, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = max_width,
		height = #lines,
		style = "minimal",
		border = "rounded",
		focusable = false,
	})

	vim.api.nvim_win_set_option(win, "wrap", true)
	vim.api.nvim_win_set_option(win, "linebreak", true)

	local source_buf = vim.api.nvim_get_current_buf()
	local close = function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end

	vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
		buffer = source_buf,
		once = true,
		callback = close,
	})

	vim.keymap.set("n", "<Esc>", function()
		close()
		vim.keymap.del("n", "<Esc>", { buffer = source_buf })
	end, { buffer = source_buf, noremap = true, silent = true })
end, { noremap = true, silent = true, desc = "Show diagnostic popup" })

vim.cmd.colorscheme("base16-black-metal")
vim.opt.termguicolors = true
vim.api.nvim_set_hl(0, "Normal", { bg = "#0d0d0d" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "#0d0d0d" })

vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#444444" })
vim.api.nvim_set_hl(0, "NoiceCmdlinePopupTitle", { fg = "#444444" })

vim.api.nvim_set_hl(0, "ErrorMsg", { fg = "#cc6666", bg = "#0d0d0d" })

-- Colorscheme variables
local orange_hex = "#ee7967"
local bg_hex = "#0d0d0d"
local white_hex = "#ffffff"
local selection_bg_hex = "#252525" -- Subtle dark charcoal for the active row

-- 1. Style the Border (Stays Orange)
vim.api.nvim_set_hl(0, "CmpMenuBorder", { fg = orange_hex, bg = bg_hex })

-- 2. Style the Suggestion Menu Inside Components
vim.api.nvim_set_hl(0, "Pmenu", { fg = white_hex, bg = bg_hex })        -- Fallback text to white
vim.api.nvim_set_hl(0, "CmpItemAbbr", { fg = white_hex, bg = bg_hex })  -- Text options are white
vim.api.nvim_set_hl(0, "CmpItemKind", { fg = orange_hex, bg = bg_hex }) -- Symbols/icons are orange

-- 3. New Selection Style: Dark gray background, Orange text/icon focus
vim.api.nvim_set_hl(0, "PmenuSel", { bg = selection_bg_hex })

-- =====================================================================
-- Custom Theme Overrides (Borders, Autocomplete, & Telescope)
-- =====================================================================
local orange_hex = "#ee7967"
local bg_hex = "#0d0d0d"
local white_hex = "#ffffff"
local selection_bg_hex = "#252525"

local function apply_custom_theme()
	-- 1. Nvim-Cmp (Autocomplete) Styles
	vim.api.nvim_set_hl(0, "CmpMenuBorder", { fg = orange_hex, bg = bg_hex })
	vim.api.nvim_set_hl(0, "Pmenu", { fg = white_hex, bg = bg_hex })
	vim.api.nvim_set_hl(0, "CmpItemAbbr", { fg = white_hex, bg = bg_hex })
	vim.api.nvim_set_hl(0, "CmpItemKind", { fg = orange_hex, bg = bg_hex })

	-- Hover behavior: ONLY background shifts, text remains white & icon remains orange
	vim.api.nvim_set_hl(0, "PmenuSel", { bg = selection_bg_hex, fg = white_hex })
	vim.api.nvim_set_hl(0, "CmpItemAbbrSel", { bg = selection_bg_hex, fg = white_hex })
	vim.api.nvim_set_hl(0, "CmpItemKindSel", { bg = selection_bg_hex, fg = orange_hex })

	-- Prevent typing matches from breaking the text colors
	vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { fg = white_hex, bg = bg_hex, bold = true })
	vim.api.nvim_set_hl(0, "CmpItemAbbrMatchSel", { fg = white_hex, bg = selection_bg_hex, bold = true })

	-- 2. Telescope Picker Styles (Esc ;, Esc Space, C-p, C-a)
	vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = orange_hex, bg = bg_hex })
	vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = orange_hex, bg = bg_hex })
	vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = orange_hex, bg = bg_hex })
	vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = orange_hex, bg = bg_hex })
	vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = selection_bg_hex, fg = white_hex })
end

-- Run immediately on boot
apply_custom_theme()

-- Re-run if colorscheme updates to prevent it from wiping our overrides
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = apply_custom_theme,
})

-- Forces the '>' inside the input/prompt bar to be flat white
vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { fg = white_hex, bg = bg_hex })
