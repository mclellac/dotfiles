-- ################################################################################
-- #                                                                              #
-- #                                      NOICE                                   #
-- #         NOTE: Replaces the UI for messages, cmdline and the popupmenu.       #
-- #                                                                              #
-- ################################################################################

return {
  -- noicer ui
  "folke/noice.nvim",
  -- enabled = false,
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    "rcarriga/nvim-notify",
  },
  config = function()
    local noice = require("noice")
    noice.setup({
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        -- text document hover
        hover = {
          -- enabled = false,
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
        -- text document signature
        signature = {
          -- enabled = false,
          auto_open = {
            enabled = true,
            trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
            luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
            throttle = 50, -- Debounce lsp signature help request by 50ms
          },
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- set true to use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
      views = {
        cmdline_popup = {
          border = {
            style = "rounded",
            padding = { 0, 0 },
          },
          filter_options = {},
        },
      },
    })
  end
}
