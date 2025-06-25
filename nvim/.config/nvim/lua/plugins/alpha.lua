-- Alpha configuration for Lazy.nvim
-- This file can be placed in lua/plugins/alpha.lua for lazy loading

return {
  "goolord/alpha-nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
  },
  event = "VimEnter",
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")
    local plenary_path = require("plenary.path")
    local cdir = vim.fn.getcwd()
    local if_nil = vim.F.if_nil

    -- Custom header with xKea instead of Neovim
    local header = {
        "                                   ",
        "                                   ",
        "    ██╗  ██╗██╗  ██╗███████╗ █████╗ ",
        "    ╚██╗██╔╝██║ ██╔╝██╔════╝██╔══██╗",
        "     ╚███╔╝ █████╔╝ █████╗  ███████║",
        "     ██╔██╗ ██╔═██╗ ██╔══╝  ██╔══██║",
        "    ██╔╝ ██╗██║  ██╗███████╗██║  ██║",
        "    ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝",
        "                                   ",
        "       " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
        "                                   ",
    }

    -- Set the header
    dashboard.section.header.val = header
    dashboard.section.header.opts.hl = "AlphaHeader"

    -- Set menu
    dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
        dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", "  Configuration", ":e $MYVIMRC <CR>"),
        dashboard.button("p", "  Plugins", ":Lazy <CR>"),
        dashboard.button("s", "  Sessions", ":Telescope session-lens search_session<CR>"),
        dashboard.button("l", "  Last session", ":SessionLoad<CR>"),
        dashboard.button("q", "  Quit", ":qa<CR>"),
    }
    dashboard.section.buttons.opts.hl = "AlphaButtons"

    -- Quote section with Lazy plugin count
    local function footer()
        local stats = require("lazy").stats()
        local total_plugins = stats.count or 0
        local datetime = os.date("%Y-%m-%d %H:%M:%S")
        local plugins_text = 
            "   " .. total_plugins .. " plugins loaded on " .. datetime
        
        local quotes = {
            "The only true wisdom is in knowing you know nothing.",
            "The unexamined life is not worth living.",
            "Debugging is twice as hard as writing the code in the first place.",
            "Code is like humor. When you have to explain it, it's bad.",
            "It's not a bug, it's an undocumented feature.",
            "First, solve the problem. Then, write the code.",
            "Always code as if the guy who ends up maintaining your code will be a violent psychopath who knows where you live.",
            "Any fool can write code that a computer can understand. Good programmers write code that humans can understand.",
            "Experience is the name everyone gives to their mistakes.",
            "If debugging is the process of removing software bugs, then programming must be the process of putting them in.",
        }
        
        math.randomseed(os.time())
        local quote = quotes[math.random(#quotes)]
        
        return plugins_text .. "\n" .. quote
    end

    dashboard.section.footer.val = footer()
    dashboard.section.footer.opts.hl = "AlphaFooter"

    -- Layout
    dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        dashboard.section.footer,
    }

    -- Cool option: Dynamic project info section
    local function get_project_info()
        local project_name = vim.fn.fnamemodify(cdir, ":t")
        
        -- Get git branch if available
        local branch = vim.fn.system("git -C " .. cdir .. " branch --show-current 2>/dev/null | tr -d '\n'")
        local git_info = branch ~= "" and "Branch: " .. branch or "Not a git repository"
        
        -- Count files (with error handling)
        local file_count = "Unknown"
        local find_command = "find " .. cdir .. " -type f -not -path '*/\\.*' | wc -l"
        local file_count_result = vim.fn.system(find_command)
        if vim.v.shell_error == 0 then
            file_count = vim.fn.trim(file_count_result)
        end
        
        return {
            "Project: " .. project_name,
            git_info,
            "Files: " .. file_count,
        }
    end

    dashboard.section.project = {
        type = "group",
        val = {
            { type = "text", val = get_project_info(), opts = { hl = "AlphaProjectInfo", position = "center" } },
        },
        opts = { spacing = 1 },
    }

    -- Insert project section into layout
    table.insert(dashboard.config.layout, 5, { type = "padding", val = 1 })
    table.insert(dashboard.config.layout, 6, dashboard.section.project)

    -- Cool option: Set custom colors for different sections
    vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#61afef" })
    vim.api.nvim_set_hl(0, "AlphaButtons", { fg = "#98c379" })
    vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#c678dd" })
    vim.api.nvim_set_hl(0, "AlphaProjectInfo", { fg = "#e5c07b" })

    -- Cool option: Add randomized splash screen
    local function random_splash()
        local splash_screens = {
            header,  -- Default xKea header
            {
                "                                   ",
                "             ▄████▄   ▒█████  ▓█████▄ ▓█████  ",
                "            ▒██▀ ▀█  ▒██▒  ██▒▒██▀ ██▌▓█   ▀  ",
                "            ▒▓█    ▄ ▒██░  ██▒░██   █▌▒███    ",
                "            ▒▓▓▄ ▄██▒▒██   ██░░▓█▄   ▌▒▓█  ▄  ",
                "            ▒ ▓███▀ ░░ ████▓▒░░▒████▓ ░▒████▒ ",
                "            ░ ░▒ ▒  ░░ ▒░▒░▒░  ▒▒▓  ▒ ░░ ▒░ ░ ",
                "              ░  ▒     ░ ▒ ▒░  ░ ▒  ▒  ░ ░  ░ ",
                "            ░        ░ ░ ░ ▒   ░ ░  ░    ░    ",
                "            ░ ░          ░ ░     ░       ░  ░ ",
                "            ░                    ░            ",
                "                     XKEA EDITION              ",
                "                                   ",
            },
            {
                "                                   ",
                "              ✘✘✘   ✘✘✘✘✘ ✘✘✘✘✘✘✘    ✘✘✘    ",
                "               ✘✘✘ ✘✘✘   ✘✘✘      ✘✘✘     ",
                "                ✘✘✘✘✘    ✘✘✘✘✘    ✘✘✘     ",
                "               ✘✘✘ ✘✘✘   ✘✘✘      ✘✘✘     ",
                "              ✘✘✘   ✘✘✘  ✘✘✘✘✘✘✘  ✘✘✘✘✘✘✘  ",
                "                                   ",
                "          Welcome to the xKea experience        ",
                "                                   ",
            },
        }
        
        math.randomseed(os.time())
        return splash_screens[math.random(#splash_screens)]
    end

    -- Uncomment to enable random splash screens
    -- dashboard.section.header.val = random_splash()

    -- Setup the dashboard
    alpha.setup(dashboard.config)
  end,
}
