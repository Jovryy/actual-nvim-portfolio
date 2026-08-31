-- NVIM Settings --
vim.opt.mouse = "a"
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.shadafile = "NONE"
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.conceallevel = 3
vim.opt.linebreak = true
vim.g.mapleader = " "

-- Lazy nvim setup --
local lazypath = vim.fn.stdpath("data") ..  "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", 
	"--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


-- Plugins --
require("lazy").setup({
  { 
    "catppuccin/nvim", 
    name = "catppuccin", 
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
      })
    end
  },
  
  -- filetree / explorer with fancy icons :)
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        view = { width = 35, side = "left" },
        actions = { open_file = { quit_on_open = false } },
		filters = { dotfiles = true},
		renderer = {
          root_folder_label = false,
		  highlight_opened_files = "all",
		  indent_markers = {
            enable = true,
            icons = {
              corner = "└",
              edge = "│",
              item = "├",
              none = " ",
            },
          },
          icons = {
		    web_devicons = { -- If Nerd Font is enabled it creates issues for some devices in the web viewer, disabling them makes it use the fallback "default" glyph.
              file = { enable = false, color = false },
              folder = { enable = false, color = false },
            },
            show = {
              file = true,
              folder = true,
              git = false,
            },
            glyphs = {
		      default = "📄",
              symlink = "🔗",
              folder = {
                arrow_closed = "▶",
                arrow_open = "▼",
				default = "📁",
                open = "📂",
                empty = "📁",
                empty_open = "📂",
		      }
            }
          }
        },
      })
	  local api = require("nvim-tree.api")
      api.events.subscribe(api.events.Event.TreeOpen, function()
        vim.schedule(function()
          api.tree.expand_all()
        end)
      end)
    end
  },

  -- Tabs
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
		  buffer_close_icon = 'x',
          show_buffer_icons = false,
		  show_buffer_close_icons = true,
          show_close_icon = false,
          always_show_bufferline = true,
        }
      })
    end
  },
 
  -- renderer for markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
	dependencies = {"nvim-tree/nvim-web-devicons"},
	ft = {"markdown"},
	config = function ()
      require("render-markdown").setup({
		heading = {enabled = false},
		paragraph = {enabled = false},
        code = {enabled = false},
        --bullet = {enabled = false},
        checkbox = {enabled = false},
        --quote = {enabled = false},
        link = {enabled = false},
		dash = {
		  enabled = true,
		  icon = "─",
		  width = "full",
		},
	  })
	end,
  },
 
}, {
   
  -- Route lockfile to RAM instead of trying to write on ronly system.
  lockfile = "/tmp/lazy-lock.json",
})

-- THEME :) --
vim.cmd[[colorscheme catppuccin]]


-- Mobile compatiblity, if terminal width is too small, dont run NvimTree on startup, and enable scrolling by tapping, as scrolling is buggy using ttyd and nvim. 
--Added 100ms delay to ensure ttyd feeds the correct width into nvim and not create race condition...
vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
				vim.defer_fn(function ()
						if vim.o.columns < 108 then
								vim.api.nvim_create_autocmd("CursorMoved", {
										pattern="*",
										command="normal! zz"
								})
								else
										vim.cmd("NvimTreeOpen")
								end
						end, 100)
				end,
})
-- Security improvement, blocks easy execution of lua commands and scripts inside the commandline
vim.api.nvim_create_autocmd("CmdlineChanged", {
		pattern = ":",
				callback = function()
						local cmd = vim.fn.getcmdline()
						if cmd:match("^%s*lua") or cmd:match("^%s*!") or cmd:match("^%s*term") then
								vim.api.nvim_input("<C-c>")
								vim.notify("Nice try! ;)", vim.log.levels.WARN)
						end
				end,
})

--  KEYBINDS --
local map = vim.keymap.set

map('n', '<C-LeftMouse>', '<Nop>')
map('n', '<C-RightMouse>', '<Nop>')
map('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
map('n', '<Tab>', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
map('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })
-- close the current file
map('n', '<leader>c', ':bdelete<CR>', { noremap = true, silent = true })
-- exit insert mode with Esc so noone gets trapped
map('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })
map('t', '<leader>t', '<Cmd>ToggleTerm<CR>', { noremap = true, silent = true })
-- security: block execution of recent (-ly tried) commands
map('n', 'q:', '<Nop>', { noremap = true, silent = true })
map('n', 'q/', '<Nop>', { noremap = true, silent = true })
map('n', 'q?', '<Nop>', { noremap = true, silent = true })
map('n', 'gQ', '<Nop>', { noremap = true, silent = true })
-- security: block weird macro recording thing
map('n', 'q', '<Nop>', { noremap = true, silent = true })
