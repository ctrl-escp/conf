-- ============================================================
-- Bootstrap lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader must be set before lazy loads plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================
-- Plugins
-- ============================================================
local plugin_specs = {

  -- Theme
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({ theme = "wave", background = { dark = "wave" } })
      vim.cmd.colorscheme("kanagawa")
    end,
  },

  -- Treesitter (semantic highlighting — load early, many plugins depend on it)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash", "javascript", "typescript", "tsx",
          "python", "lua", "json", "yaml", "html", "css",
        },
        highlight = { enable = true },
        indent   = { enable = true },
      })
    end,
  },

  -- LSP
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },

  -- Completion engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        filters = { dotfiles = false },
        git     = { enable = true },
      })
    end,
  },

  -- Jump motions (replaces easymotion)
  {
    "folke/flash.nvim",
    config = function()
      require("flash").setup()
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "kanagawa" } })
    end,
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
  { "tpope/vim-fugitive" },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require("telescope").setup()
      require("telescope").load_extension("fzf")
    end,
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python             = { "black", "isort" },
          javascript         = { "prettier" },
          typescript         = { "prettier" },
          javascriptreact    = { "prettier" },
          typescriptreact    = { "prettier" },
          css                = { "prettier" },
          html               = { "prettier" },
          json               = { "prettier" },
          yaml               = { "prettier" },
          sh                 = { "shfmt" },
          bash               = { "shfmt" },
          zsh                = { "shfmt" },
        },
        format_on_save = { timeout_ms = 500, lsp_fallback = true },
      })
    end,
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("lint").linters_by_ft = {
        python     = { "flake8" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        sh         = { "shellcheck" },
        bash       = { "shellcheck" },
        zsh        = { "shellcheck" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function() require("lint").try_lint() end,
      })
    end,
  },

  -- Editing
  {
    "kylechui/nvim-surround",
    config = function() require("nvim-surround").setup() end,
  },
  {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup() end,
  },
  {
    "numToStr/Comment.nvim",
    config = function() require("Comment").setup() end,
  },
  { "wellle/targets.vim" },
  { "editorconfig/editorconfig-vim" },

  -- UI helpers
  {
    "folke/which-key.nvim",
    config = function() require("which-key").setup() end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("trouble").setup() end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function() require("todo-comments").setup() end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function() require("ibl").setup() end,
  },

  -- ============================================================
  -- AI — local Ollama (http://localhost:11434)
  -- ============================================================

  -- Inline ghost-text completion + nvim-cmp source via Ollama
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("minuet").setup({
        provider = "ollama",
        provider_options = {
          ollama = {
            model    = "qwen2.5-coder:7b",
            end_point = "http://localhost:11434/api/chat",
            optional = { max_tokens = 256, top_p = 0.9 },
          },
        },
        throttle = 1000,   -- ms between completion requests
        notify   = "error",
      })
    end,
  },

  -- AI chat / inline actions via Ollama
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        adapters = {
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
              url = "http://localhost:11434/api/chat",
              schema = {
                model = { default = "qwen2.5-coder:7b" },
              },
            })
          end,
        },
        strategies = {
          chat   = { adapter = "ollama" },
          inline = { adapter = "ollama" },
        },
      })
    end,
  },
}

-- Local-only plugins: create ~/.config/nvim/lua/local-plugins.lua to add them
if vim.fn.filereadable(vim.fn.stdpath("config") .. "/lua/local-plugins.lua") == 1 then
  table.insert(plugin_specs, { import = "local-plugins" })
end

require("lazy").setup(plugin_specs)

-- ============================================================
-- General Settings
-- ============================================================
vim.opt.encoding      = "utf-8"
vim.opt.number        = true
vim.opt.relativenumber = true
vim.opt.mouse         = "a"
vim.opt.hidden        = true
vim.opt.autoread      = true
vim.opt.hlsearch      = true
vim.opt.incsearch     = true
vim.opt.ignorecase    = true
vim.opt.smartcase     = true
vim.opt.expandtab     = true
vim.opt.smarttab      = true
vim.opt.shiftround    = true
vim.opt.autoindent    = true
vim.opt.smartindent   = true
vim.opt.backup        = false
vim.opt.writebackup   = false
vim.opt.swapfile      = false
vim.opt.wildmenu      = true
vim.opt.completeopt   = { "menu", "menuone", "noselect" }
vim.opt.wrap          = false
vim.opt.textwidth     = 79
vim.opt.colorcolumn   = "80"
vim.opt.signcolumn    = "yes"
vim.opt.updatetime    = 300
vim.opt.termguicolors = true
vim.opt.laststatus    = 2
vim.opt.shortmess:append("c")

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  callback = function() vim.cmd("checktime") end,
})

-- ============================================================
-- Language-Specific Settings
-- ============================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern  = "python",
  callback = function()
    vim.opt_local.tabstop     = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.shiftwidth  = 4
    vim.opt_local.textwidth   = 88
    vim.opt_local.colorcolumn = "89"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json" },
  callback = function()
    vim.opt_local.tabstop     = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth  = 2
    vim.opt_local.colorcolumn = "100"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "sh", "bash", "zsh" },
  callback = function()
    vim.opt_local.tabstop     = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth  = 2
    vim.opt_local.colorcolumn = "80"
  end,
})

-- ============================================================
-- LSP Setup
-- ============================================================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed    = { "bashls", "ts_ls", "pyright" },
  automatic_installation = true,
})

local lspconfig    = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

for _, server in ipairs({ "bashls", "ts_ls", "pyright" }) do
  lspconfig[server].setup({ capabilities = capabilities })
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(keys, fn) vim.keymap.set("n", keys, fn, { buffer = ev.buf }) end
    map("gd",          vim.lsp.buf.definition)
    map("gy",          vim.lsp.buf.type_definition)
    map("gi",          vim.lsp.buf.implementation)
    map("gr",          vim.lsp.buf.references)
    map("K",           vim.lsp.buf.hover)
    map("<leader>rn",  vim.lsp.buf.rename)
    map("<leader>ca",  vim.lsp.buf.code_action)
    map("[g",          vim.diagnostic.goto_prev)
    map("]g",          vim.diagnostic.goto_next)
  end,
})

-- ============================================================
-- Completion Setup
-- ============================================================
local cmp     = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"]      = cmp.mapping.confirm({ select = false }),
    ["<C-e>"]     = cmp.mapping.abort(),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "minuet" },    -- Ollama AI completions in the same menu
  }, {
    { name = "buffer" },
    { name = "path" },
  }),
})

-- ============================================================
-- Keybindings
-- ============================================================

-- Flash jump (Space replaces easymotion-bd-w)
vim.keymap.set({ "n", "x", "o" }, "<Space>", function() require("flash").jump() end)
vim.keymap.set({ "n", "x", "o" }, "<leader>j", function()
  require("flash").jump({ search = { forward = true, wrap = false } })
end)
vim.keymap.set({ "n", "x", "o" }, "<leader>k", function()
  require("flash").jump({ search = { forward = false, wrap = false } })
end)

-- Telescope
vim.keymap.set("n", "<leader>f",  "<cmd>Telescope find_files<CR>")
vim.keymap.set("n", "<leader>b",  "<cmd>Telescope buffers<CR>")
vim.keymap.set("n", "<leader>rg", "<cmd>Telescope live_grep<CR>")
vim.keymap.set("n", "<leader>t",  "<cmd>Telescope tags<CR>")

-- File tree
vim.keymap.set("n", "<leader>n",  "<cmd>NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>nf", "<cmd>NvimTreeFindFile<CR>")

-- Diagnostics
vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<CR>")

-- Format
vim.keymap.set("n", "<leader>py", function()
  require("conform").format({ async = true, lsp_fallback = true })
end)

-- AI
vim.keymap.set("n", "<leader>ai", "<cmd>CodeCompanionChat<CR>")
vim.keymap.set("v", "<leader>ai", "<cmd>CodeCompanionChat<CR>")

-- Save / quit
vim.keymap.set("n", "<leader>w",  "<cmd>w<CR>")
vim.keymap.set("n", "<leader>q",  "<cmd>q<CR>")
vim.keymap.set("n", "<leader>wq", "<cmd>wq<CR>")

-- Split navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>")
vim.keymap.set("n", "<leader>bp", "<cmd>bprev<CR>")
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>")

-- Misc
vim.keymap.set("n", "<leader><Space>", "<cmd>nohlsearch<CR>")
vim.keymap.set("v", "<",               "<gv")
vim.keymap.set("v", ">",               ">gv")
vim.keymap.set("v", "<leader>s",       ":sort<CR>")
vim.keymap.set("n", "Q",               "gqap")
vim.keymap.set("v", "Q",               "gq")
vim.keymap.set("i", "jk",              "<Esc>")
vim.keymap.set("i", "kj",              "<Esc>")

-- ============================================================
-- Keybindings Summary (which-key will also show these)
-- ============================================================
-- <Space>        - Flash jump (word-level, bidirectional)
-- <leader>f      - Find files (Telescope)
-- <leader>b      - Buffers (Telescope)
-- <leader>rg     - Live grep (Telescope + ripgrep)
-- <leader>n      - Toggle file tree
-- <leader>nf     - Reveal current file in tree
-- <leader>py     - Format buffer (conform)
-- <leader>rn     - Rename symbol (LSP)
-- <leader>ca     - Code action (LSP)
-- <leader>xx     - Diagnostics list (Trouble)
-- <leader>ai     - AI chat (CodeCompanion → Ollama)
-- gd             - Go to definition
-- gr             - Go to references
-- K              - Hover docs
-- [g / ]g        - Prev/next diagnostic
-- gcc            - Comment line
-- gc{motion}     - Comment motion
