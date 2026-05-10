-- =============================================================================
-- plugins.lua — Neovim plugin configuration via lazy.nvim
-- Author : Prashant Gautam (github.com/PrashantGautam-alt)
-- Neovim : 0.11+   lazy.nvim : stable
-- =============================================================================
-- Plugin list (in order below):
--   1.  lazy.nvim        — plugin manager bootstrap
--   2.  kanagawa.nvim    — colorscheme
--   3.  transparent.nvim — transparent background toggle
--   4.  lualine.nvim     — statusline
--   5.  nvim-treesitter  — syntax / textobjects
--   6.  telescope.nvim   — fuzzy finder
--   7.  neo-tree.nvim    — file explorer
--   8.  mason.nvim       — LSP / tool installer
--   9.  mason-lspconfig  — bridge: mason ↔ nvim-lspconfig
--   10. nvim-lspconfig   — LSP client configs (Neovim 0.11 API)
--   11. blink.cmp        — completion engine
--   12. conform.nvim     — formatter
--   13. which-key.nvim   — keymap cheatsheet
--   14. nvim-autopairs   — auto-close brackets / quotes
-- =============================================================================


-- =============================================================================
-- BOOTSTRAP: lazy.nvim
-- Clones lazy.nvim into the Neovim data directory on first launch.
-- Nothing below this block runs until lazy is available.
-- =============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        lazyrepo, lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)


-- =============================================================================
-- PLUGINS
-- Each entry is a lazy.nvim plugin spec table.
-- "owner/repo" strings are treated as GitHub repos automatically.
-- =============================================================================
require("lazy").setup({

    -- =========================================================================
    -- 1. COLORSCHEME — kanagawa
    --    https://github.com/rebelot/kanagawa.nvim
    --    Variants: kanagawa-wave (dark) | kanagawa-dragon | kanagawa-lotus (light)
    -- =========================================================================
    {
        "rebelot/kanagawa.nvim",
        lazy = false,    -- load at startup so the colorscheme is available immediately
        priority = 1000, -- load before any other start plugin
        config = function()
            vim.cmd.colorscheme("kanagawa-wave")
        end,
    },

    -- =========================================================================
    -- 2. TRANSPARENT BACKGROUND
    --    https://github.com/xiyaowong/transparent.nvim
    --    Lets you toggle background transparency with :TransparentToggle
    --    Works well with terminal transparency (alacritty / kitty / etc.)
    -- =========================================================================
    {
        "xiyaowong/transparent.nvim",
        lazy = false,
    },

    -- =========================================================================
    -- 3. STATUSLINE — lualine
    --    https://github.com/nvim-lualine/lualine.nvim
    --    Shows mode, branch, diff, diagnostics, filename, encoding, filetype,
    --    progress, and cursor location in a clean bar.
    -- =========================================================================
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy", -- defer until UI is ready
        config = function()
            require("lualine").setup({
                options           = {
                    icons_enabled        = true,
                    theme                = "auto", -- inherit from active colorscheme
                    -- Powerline-style separators (requires a Nerd Font)
                    component_separators = { left = "", right = "" },
                    section_separators   = { left = "", right = "" },
                    disabled_filetypes   = {
                        statusline = { "neo-tree" }, -- hide bar in the file-tree panel
                        winbar     = {},
                    },
                    always_divide_middle = true,
                    globalstatus         = true, -- single statusline for all windows (Neovim 0.7+)
                    -- Default refresh is 1 000 ms; 500 is a good balance between
                    -- responsiveness and CPU usage.
                    refresh              = {
                        statusline = 500,
                        tabline    = 500,
                        winbar     = 500,
                    },
                },

                -- Left side  : mode | branch + diff + diagnostics | full file path
                -- Right side : encoding | file format | filetype icon | progress | location
                sections          = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = {
                        {
                            "filename",
                            path = 3, -- 0=filename, 1=relative, 2=absolute, 3=relative+shortened
                        },
                    },
                    lualine_x = {
                        "encoding",
                        "fileformat",
                        {
                            "filetype",
                            colored   = true, -- color the icon to match the filetype color
                            icon_only = true, -- show icon only, no text label
                            icon      = { align = "right" },
                        },
                    },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },

                -- Inactive windows get a minimal bar (filename + cursor position only)
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },

                tabline           = {},
                winbar            = {},
                inactive_winbar   = {},
                extensions        = { "neo-tree", "lazy", "mason" }, -- enable built-in lualine extensions
            })
        end,
    },

    -- =========================================================================
    -- 4. TREESITTER — syntax highlighting + smart textobjects
    --    https://github.com/nvim-treesitter/nvim-treesitter
    --
    --    Textobjects let you select/move by function, class, parameter, etc.
    --    e.g. vaf → select around function | dif → delete inside function
    --
    --    Keymaps (incremental selection):
    --      <Leader>ss → start selection
    --      <Leader>si → expand to next node
    --      <Leader>sc → expand to scope
    --      <Leader>sd → shrink selection
    -- =========================================================================
    {
        "nvim-treesitter/nvim-treesitter",
        -- nvim-treesitter-textobjects must be a dependency so it loads first
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        build = ":TSUpdate", -- recompile parsers after plugin updates
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter").setup({
                -- Always-installed parsers; others are pulled in by auto_install below
                ensure_installed = {
                    "c", "lua", "vim", "vimdoc", "query",
                    "cpp", "rust", "python", "go",
                },
                auto_install = true, -- silently install parsers for new filetypes

                highlight = { enable = true },

                -- Incremental selection: grow/shrink the visual selection by syntax node
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection    = "<Leader>ss",
                        node_incremental  = "<Leader>si",
                        scope_incremental = "<Leader>sc",
                        node_decremental  = "<Leader>sd",
                    },
                },

                -- Textobjects: select/move/swap by code structure
                textobjects = {
                    select = {
                        enable                         = true,
                        lookahead                      = true, -- jump forward to the next textobject if needed
                        keymaps                        = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = { query = "@class.inner", desc = "Select inner class" },
                            ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select scope" },
                        },
                        selection_modes                = {
                            ["@parameter.outer"] = "v",     -- charwise
                            ["@function.outer"]  = "V",     -- linewise
                            ["@class.outer"]     = "<c-v>", -- blockwise
                        },
                        include_surrounding_whitespace = true,
                    },
                },
            })
        end,
    },

    -- =========================================================================
    -- 5. TELESCOPE — fuzzy finder
    --    https://github.com/nvim-telescope/telescope.nvim
    --
    --    Keymaps:
    --      <Leader>fd → find files
    --    Add more pickers as needed (live_grep, buffers, help_tags, etc.)
    -- =========================================================================
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "Telescope", -- lazy-load on first :Telescope call
        keys = {
            { "<Leader>fd", function() require("telescope.builtin").find_files() end, desc = "Find files" },
            { "<Leader>fg", function() require("telescope.builtin").live_grep() end,  desc = "Live grep" },
            { "<Leader>fb", function() require("telescope.builtin").buffers() end,    desc = "Buffers" },
            { "<Leader>fh", function() require("telescope.builtin").help_tags() end,  desc = "Help tags" },
        },
    },

    -- =========================================================================
    -- 6. FILE EXPLORER — neo-tree
    --    https://github.com/nvim-neo-tree/neo-tree.nvim
    --
    --    Keymaps:
    --      <Leader>e  → toggle file tree
    --      <Leader>bf → buffer list
    --      <Leader>gs → git status panel
    -- =========================================================================
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch       = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        cmd          = "Neotree",
        keys         = {
            { "<Leader>e",  "<cmd>Neotree toggle<CR>",     desc = "Toggle Neo-tree" },
            { "<Leader>bf", "<cmd>Neotree buffers<CR>",    desc = "Neo-tree buffers" },
            { "<Leader>gs", "<cmd>Neotree git_status<CR>", desc = "Neo-tree git status" },
        },
        config       = function()
            require("neo-tree").setup({
                close_if_last_window      = true, -- close Neovim when neo-tree is the last window
                popup_border_style        = "rounded",
                enable_git_status         = true,
                enable_diagnostics        = true,

                window                    = {
                    position = "left",
                    width    = 30,
                },

                filesystem                = {
                    follow_current_file = { enabled = true }, -- highlight the open file
                    hijack_netrw_behavior = "open_default",   -- replace netrw
                },

                -- Nerd Font symbols for git status indicators
                default_component_configs = {
                    git_status = {
                        symbols = {
                            added     = "✚",
                            modified  = "",
                            deleted   = "✖",
                            renamed   = "󰁕",
                            untracked = "",
                            ignored   = "",
                            unstaged  = "󰄱",
                            staged    = "",
                            conflict  = "",
                        },
                    },
                },
            })
        end,
    },

    -- =========================================================================
    -- 7. MASON — LSP / DAP / linter / formatter installer
    --    https://github.com/mason-org/mason.nvim
    --    UI: :Mason   Install: :MasonInstall <name>
    -- =========================================================================
    {
        "mason-org/mason.nvim",
        cmd    = "Mason",
        config = function()
            require("mason").setup()
        end,
    },

    -- =========================================================================
    -- 8. MASON-LSPCONFIG — auto-install LSP servers via Mason
    --    https://github.com/mason-org/mason-lspconfig.nvim
    --    Lists servers to keep installed; add names from :Mason's list.
    -- =========================================================================
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "clangd",        -- C / C++
                    "pyright",       -- Python
                    "lua_ls",        -- Lua (Neovim config)
                    "rust_analyzer", -- Rust
                },
                automatic_installation = true,
            })
        end,
    },

    -- =========================================================================
    -- 9. NVIM-LSPCONFIG — configure LSP clients (Neovim 0.11 API)
    --    https://github.com/neovim/nvim-lspconfig
    --
    --    Neovim 0.11 introduced vim.lsp.config() + vim.lsp.enable() to replace
    --    the older lspconfig.SERVER.setup() pattern. Both still work, but the
    --    new API is the recommended path going forward.
    --
    --    Useful LSP keymaps (set up in the on_attach or globally via LspAttach):
    --      gd  → go to definition
    --      K   → hover documentation
    --      grn → rename symbol
    --      gra → code actions
    -- =========================================================================
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
            "saghen/blink.cmp", -- blink provides enhanced LSP capabilities
        },
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            -- Pull extended LSP capabilities from blink.cmp (adds snippet support, etc.)
            local capabilities = require("blink.cmp").get_lsp_capabilities()

            -- Server name → extra config table (empty = use defaults)
            local servers = {
                clangd        = {},
                pyright       = {},
                rust_analyzer = {},
                gopls         = {},
                lua_ls        = {
                    settings = {
                        Lua = {
                            diagnostics = { globals = { "vim" } }, -- silence "undefined global vim"
                            workspace   = { checkThirdParty = false },
                            telemetry   = { enable = false },
                        },
                    },
                },
            }

            for name, conf in pairs(servers) do
                conf.capabilities = capabilities
                vim.lsp.config(name, conf) -- register config
                vim.lsp.enable(name)       -- activate server (required in 0.11 API)
            end

            -- Global LSP keymaps — active only when an LSP is attached to the buffer
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
                    end
                    map("gd", vim.lsp.buf.definition, "Go to definition")
                    map("gD", vim.lsp.buf.declaration, "Go to declaration")
                    map("gi", vim.lsp.buf.implementation, "Go to implementation")
                    map("gr", vim.lsp.buf.references, "References")
                    map("K", vim.lsp.buf.hover, "Hover docs")
                    map("<Leader>rn", vim.lsp.buf.rename, "Rename symbol")
                    map("<Leader>ca", vim.lsp.buf.code_action, "Code actions")
                end,
            })
        end,
    },

    -- =========================================================================
    -- 10. COMPLETION — blink.cmp
    --     https://github.com/saghen/blink.cmp
    --     Faster alternative to nvim-cmp, written in Rust.
    --     Sources: LSP | path | snippets (friendly-snippets) | buffer
    --
    --     Key bindings (default preset):
    --       C-Space → open / refresh menu
    --       C-n / C-p or ↑↓ → navigate items
    --       C-y → accept selected item
    --       C-e → close menu
    -- =========================================================================
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" }, -- VSCode-style snippet collection
        version = "1.*",                                   -- use pre-built binaries; pin to major version for stability
        opts = {
            keymap     = { preset = "default" },
            appearance = { nerd_font_variant = "mono" },
            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
            },
            sources    = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            -- prefer_rust_with_warning falls back to Lua if the Rust binary is missing
            fuzzy      = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },

    -- =========================================================================
    -- 11. FORMATTER — conform.nvim
    --     https://github.com/stevearc/conform.nvim
    --     Runs external formatters on save.
    --     Formatters must be installed separately (via Mason or your system).
    --     :Mason → search for stylua / black / clang-format / etc.
    -- =========================================================================
    {
        "stevearc/conform.nvim",
        event = "BufWritePre", -- lazy-load just before the first save
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    lua    = { "stylua" },
                    python = { "black" },
                    c      = { "clang_format" },
                    cpp    = { "clang_format" },
                    rust   = { "rustfmt" },
                    go     = { "gofmt" },
                },
                -- Format synchronously on save; fall back to LSP if no formatter found
                format_on_save = {
                    timeout_ms   = 500,
                    lsp_fallback = true,
                },
            })
        end,
    },

    -- =========================================================================
    -- 12. KEYMAP CHEATSHEET — which-key
    --     https://github.com/folke/which-key.nvim
    --     Shows a popup of available keybindings when you pause mid-chord.
    --     No extra config needed; it auto-discovers mappings.
    -- =========================================================================
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup()
            -- Optional: label your <Leader> groups so the popup is more readable
            require("which-key").add({
                { "<Leader>f", group = "Find (Telescope)" },
                { "<Leader>b", group = "Buffers" },
                { "<Leader>g", group = "Git" },
                { "<Leader>r", group = "Refactor / Rename" },
                { "<Leader>c", group = "Code actions" },
                { "<Leader>s", group = "Selection (Treesitter)" },
            })
        end,
    },

    -- =========================================================================
    -- 13. AUTO-PAIRS — nvim-autopairs
    --     https://github.com/windwp/nvim-autopairs
    --     Auto-closes (), [], {}, "", '', `` in insert mode.
    --     Integrates with blink.cmp so accepting a completion doesn't break pairs.
    -- =========================================================================
    {
        "windwp/nvim-autopairs",
        event  = "InsertEnter",
        config = true, -- calls require("nvim-autopairs").setup() with defaults
    },

}) -- end require("lazy").setup
