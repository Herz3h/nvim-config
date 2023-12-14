-- Set Python Host Prog
vim.g.python_host_prog = '/usr/local/bin/python'
vim.g.python3_host_prog = '/usr/bin/python3'
if vim.fn.has('macunix') == 1 then
    vim.g.python3_host_prog = '/usr/bin/python3'
end

-- General Configuration
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.number = true
vim.o.signcolumn = 'yes'
vim.o.guifont = 'Monaco:h11'
vim.o.expandtab = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.smarttab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.nohidden = true
vim.o.nobackup = true
vim.o.noswapfile = true
vim.o.nowritebackup = true
vim.o.autoread = true
vim.o.autowrite = true
vim.o.autowriteall = true
vim.o.foldenable = true
vim.o.lazyredraw = true
vim.filetype.plugin = 'on'
vim.api.nvim_exec('iabbrev {  { ', false)
vim.o.regexpengine = 1

-- Theme
vim.cmd('syntax enable')
vim.o.termguicolors = true

-- Timeout
vim.o.timeout = true
vim.o.ttimeout = true
vim.o.timeoutlen = 500



local plugins = {
    -- THEMES
    { 'flazz/vim-colorschemes', lazy = false },
    {
        'rafi/awesome-vim-colorschemes',
        lazy = false ,
        config = function()
            vim.cmd('colorscheme adventurous')
        end
    },

    -- UI
    { 'nvim-lua/lsp-status.nvim' },
    { 'liuchengxu/eleline.vim' },

    -- TPOPE
    { 'tpope/vim-abolish' },
    { 'tpope/vim-unimpaired' },
    { 'tpope/vim-repeat' },
    { 'tpope/vim-surround' },
    { 'tpope/vim-dispatch' },
    { 'tpope/vim-eunuch' },
    { 'tpope/vim-vinegar' },
    { 'tpope/vim-commentary' },

    -- NAVIGATION
    { 'easymotion/vim-easymotion' },

    -- AUTOCOMPLETE
    {
        'neoclide/coc.nvim',
        branch = 'release',
        config = function()
            -- COC.NVIM
            -- Some servers have issues with backup files, see #649
            vim.opt.backup = false
            vim.opt.writebackup = false

            -- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
            -- delays and poor user experience
            vim.opt.updatetime = 300

            -- Always show the signcolumn, otherwise it would shift the text each time
            -- diagnostics appeared/became resolved
            vim.opt.signcolumn = "yes"

            local keyset = vim.keymap.set
            -- Autocomplete
            function _G.check_back_space()
                local col = vim.fn.col('.') - 1
                return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
            end

            -- Use Tab for trigger completion with characters ahead and navigate
            -- NOTE: There's always a completion item selected by default, you may want to enable
            -- no select by setting `"suggest.noselect": true` in your configuration file
            -- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
            -- other plugins before putting this into your config
            local opts = {silent = true, noremap = true, expr = true, replace_keycodes = false}
            keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
            keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

            -- Make <CR> to accept selected completion item or notify coc.nvim to format
            -- <C-g>u breaks current undo, please make your own choice
            keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

            -- Use <c-j> to trigger snippets
            keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
            -- Use <c-space> to trigger completion
            keyset("i", "<c-space>", "coc#refresh()", {silent = true, expr = true})

            -- Use `[g` and `]g` to navigate diagnostics
            -- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
            keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {silent = true})
            keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {silent = true})

            -- GoTo code navigation
            keyset("n", "gd", "<Plug>(coc-definition)", {silent = true})
            keyset("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
            keyset("n", "gi", "<Plug>(coc-implementation)", {silent = true})
            keyset("n", "gr", "<Plug>(coc-references)", {silent = true})


            -- Use K to show documentation in preview window
            function _G.show_docs()
                local cw = vim.fn.expand('<cword>')
                if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
                    vim.api.nvim_command('h ' .. cw)
                elseif vim.api.nvim_eval('coc#rpc#ready()') then
                    vim.fn.CocActionAsync('doHover')
                else
                    vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
                end
            end
            keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})


            -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
            vim.api.nvim_create_augroup("CocGroup", {})
            vim.api.nvim_create_autocmd("CursorHold", {
                group = "CocGroup",
                command = "silent call CocActionAsync('highlight')",
                desc = "Highlight symbol under cursor on CursorHold"
            })


            -- Symbol renaming
            keyset("n", "<leader>rn", "<Plug>(coc-rename)", {silent = true})


            -- Setup formatexpr specified filetype(s)
            vim.api.nvim_create_autocmd("FileType", {
                group = "CocGroup",
                pattern = "typescript,json",
                command = "setl formatexpr=CocAction('formatSelected')",
                desc = "Setup formatexpr specified filetype(s)."
            })

            -- Update signature help on jump placeholder
            vim.api.nvim_create_autocmd("User", {
                group = "CocGroup",
                pattern = "CocJumpPlaceholder",
                command = "call CocActionAsync('showSignatureHelp')",
                desc = "Update signature help on jump placeholder"
            })

            -- Apply codeAction to the selected region
            -- Example: `<leader>aap` for current paragraph
            local opts = {silent = true, nowait = true}
            keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
            keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)

            -- Remap keys for apply code actions at the cursor position.
            keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
            -- Remap keys for apply source code actions for current file.
            keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
            -- Apply the most preferred quickfix action on the current line.
            keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)

            -- Remap keys for apply refactor code actions.
            keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
            keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
            keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })

            -- Run the Code Lens actions on the current line
            keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)


            -- Map function and class text objects
            -- NOTE: Requires 'textDocument.documentSymbol' support from the language server
            keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
            keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
            keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
            keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
            keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
            keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
            keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
            keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)


            -- Remap <C-f> and <C-b> to scroll float windows/popups
            ---@diagnostic disable-next-line: redefined-local
            local opts = {silent = true, nowait = true, expr = true}
            keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
            keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
            keyset("i", "<C-f>",
                   'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
            keyset("i", "<C-b>",
                   'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
            keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
            keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)


            -- Use CTRL-S for selections ranges
            -- Requires 'textDocument/selectionRange' support of language server
            keyset("n", "<C-s>", "<Plug>(coc-range-select)", {silent = true})
            keyset("x", "<C-s>", "<Plug>(coc-range-select)", {silent = true})


            -- Add `:Format` command to format current buffer
            vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

            -- " Add `:Fold` command to fold current buffer
            vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {nargs = '?'})

            -- Add `:OR` command for organize imports of the current buffer
            vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

            -- Add (Neo)Vim's native statusline support
            -- NOTE: Please see `:h coc-status` for integrations with external plugins that
            -- provide custom statusline: lightline.vim, vim-airline
            vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

            -- Mappings for CoCList
            -- code actions and coc stuff
            ---@diagnostic disable-next-line: redefined-local
            local opts = {silent = true, nowait = true}
            -- Show all diagnostics
            keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts)
            -- Manage extensions
            keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", opts)
            -- Show commands
            keyset("n", "<space>c", ":<C-u>CocList commands<cr>", opts)
            -- Find symbol of current document
            keyset("n", "<space>o", ":<C-u>CocList outline<cr>", opts)
            -- Search workspace symbols
            keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts)
            -- Resume latest coc list
            keyset("n", "<space>p", ":<C-u>CocListResume<cr>", opts)
        end
    },
    { 'wellle/tmux-complete.vim' },
    { 'SirVer/ultisnips' },
    { 'algotech/ultisnips-php' },
    { 'honza/vim-snippets' },
    { 'neovim/nvim-lspconfig' },

    -- FILES
    { 'nvim-lua/plenary.nvim' },
    { 'kyazdani42/nvim-web-devicons' },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        config = function()
            require('telescope').setup{
                pickers = {
                    buffers = {
                        sort_lastused = true,
                        ignore_current_buffer = true,
                        sort_mru = true
                    }
                }
            }
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>f', builtin.find_files, {})
            vim.keymap.set('n', '<leader>gl', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>b', builtin.buffers, {})
        end,
        dependencies = {  'nvim-lua/plenary.nvim' },
    },
    { 'nvim-treesitter/nvim-treesitter' },
    { 'nvim-tree/nvim-web-devicons' },


    -- GIT
    { 'tpope/vim-fugitive' },
    { 'tommcdo/vim-fugitive-blame-ext' },
    { 'whiteinge/diffconflicts' },

    -- LINT
    {
        'w0rp/ale',
        config = function()
            -- ALE
            vim.g.ale_php_phpstan_executable = "./vendor/bin/phpstan"
            vim.g.ale_php_phpstan_options = "--level max"
            vim.g.ale_php_cs_fixer_executable = "./vendor/friendsofphp/php-cs-fixer/php-cs-fixer"
            vim.g.ale_php_cs_fixer_options = "--rules='{\"braces\": {\"position_after_control_structures\": \"next\", \"position_after_functions_and_oop_constructs\": \"next\", \"position_after_anonymous_constructs\": \"next\"} }'"
            vim.g.ale_virtualtext_cursor = 0
            vim.g.ale_fixers = {
                md = {"trim_whitespace"},
                php = {"php_cs_fixer", "trim_whitespace"},
                javascript = {"eslint", "trim_whitespace"},
                ruby = {"trim_whitespace"},
                vue = {"eslint", "trim_whitespace"},
                yaml = {"trim_whitespace"},
                twig = {"trim_whitespace"},
                dart = {"trim_whitespace"},
                lua = {"trim_whitespace"},
            }
            vim.g.ale_fix_on_save = 1
        end
    },
    {
        'folke/trouble.nvim',
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },


    -- FORMAT
    { 'sheerun/vim-polyglot' },
    { 'leafgarland/typescript-vim' },
    { 'peitalin/vim-jsx-typescript' },
    { 'junegunn/vim-easy-align' },
    { 'ntpeters/vim-better-whitespace' },
    { 'Yggdroot/indentLine' },

    -- MOTIONS
    { 'michaeljsmith/vim-indent-object' },
    { 'wellle/targets.vim' },
    { 'machakann/vim-sandwich' },
    { 'kana/vim-operator-user' },

    -- SEARCH
    { 'henrik/vim-indexed-search' },
    { 'mhinz/vim-grepper' },
    { 'dkprice/vim-easygrep' },

    -- MISC
    { 'romainl/vim-qf' },
    { 'simeji/winresizer' },
    { 'sjl/gundo.vim' },
    { 'mhinz/vim-startify' },
    { 'benmills/vimux' },
    { '907th/vim-auto-save' },
    { 'terryma/vim-multiple-cursors' },
    { 'svermeulen/vim-yoink' },
    -- 'jiangmiao/auto-pairs' },
    { 'AndrewRadev/linediff.vim' },
    -- 'andymass/vim-matchup' },
    { 'mbbill/undotree' },
    { 'norcalli/nvim-colorizer.lua' },
    { 'williamboman/mason.nvim' },

    -- PHP
    -- { 'phpactor/phpactor', {'for': 'php', 'do': 'composer install'}
    { 'tobyS/php-accessors.vim' },
    { 'docteurklein/php-getter-setter.vim' },
    { 'adoy/vim-php-refactoring-toolbox' },
    { 'tobyS/pdv' },

    { 'mfussenegger/nvim-dap' },
    { 'rcarriga/nvim-dap-ui' },
    { 'theHamsta/nvim-dap-virtual-text' },
    { 'nvim-telescope/telescope-dap.nvim' },

    -- HTML
    { 'mattn/emmet-vim' },

    -- TWIG
    { 'nelsyeung/twig.vim' },

    -- RUBY
    { 'vim-utils/vim-ruby-fold' },
    { 'vim-ruby/vim-ruby' },

    -- DART
    { 'dart-lang/dart-vim-plugin' },
    { 'tiagofumo/dart-vim-flutter-layout' },
    { 'nvim-lua/plenary.nvim' },
    { 'stevearc/dressing.nvim' }, -- optional for vim.ui.select
    { 'akinsho/flutter-tools.nvim' },
}


-- LAZY.NVIM
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(plugins, opts)

-- Plugin options + Mappings
vim.g.mapleader = " "

vim.api.nvim_set_var('coc_node_path', '/Users/jpldev/.nvm/versions/node/v16.20.2/bin/node')

-- Mappings
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true })
vim.api.nvim_set_keymap('i', 'kj', '<Esc>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-W>j', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-W>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-h>', '<C-W>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-W>l', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>w', ':w!<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>ve', ':e ~/.config/nvim/init.lua<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>pe', ':e app/config/parameters.yml<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>vr', ':so ~/.vimrc<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>p', '"0p', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>P', '"0P', { noremap = true })

-- Search and Replace
vim.api.nvim_set_keymap('n', '<leader>s', ':%s//g<Left><Left>', { noremap = true })
vim.api.nvim_create_user_command('W', 'w !sudo tee % > /dev/null', {})

-- Plugin specific configurations (examples)
vim.g.ruby_fold_lines_limit = 200
vim.g.UltiSnipsExpandTrigger = "<c-j>"
vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
vim.g.UltiSnipsRemoveSelectModeMappings = 0
vim.g.grepprg = 'ag'
vim.g.EasyGrepCommand = 1
vim.g.EasyGrepRecursive = 1


-- Grepper
vim.g.grepper = {
    tools = {'rg', 'ag', 'ack-grep', 'grep', 'findstr', 'ack', 'pt', 'sift', 'git'}
}

-- PHP Actor
-- Lua equivalent configurations and mappings

-- Set diff options
vim.o.diffopt = vim.o.diffopt..",internal,algorithm:patience,iwhiteall,horizontal"

vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end)
