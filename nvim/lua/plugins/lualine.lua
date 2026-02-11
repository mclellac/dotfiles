return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    -- Add custom components or modify existing ones
    table.insert(opts.sections.lualine_x, 2, {
      function()
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
        if #clients == 0 then
          return ""
        end
        local names = {}
        for _, client in ipairs(clients) do
          table.insert(names, client.name)
        end
        return "LSP: " .. table.concat(names, ", ")
      end,
      cond = function()
        return not vim.tbl_isempty(vim.lsp.get_active_clients({ bufnr = 0 }))
      end,
      color = { fg = "#a3be8c" }, -- Example color
    })

    -- Example: Customize lualine_c (middle section) to show filename and filetype
    opts.sections.lualine_c = {
      {
        "filename",
        path = 1, -- 1: relative path, 2: absolute path, 3: full path
        file_status = true, -- Show if modified, readonly, etc.
        shorting_target = 40,
        symbols = {
          modified = "  ",
          readonly = "  ",
          untracked = "  ",
          nonfile = "  ",
        },
      },
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
    }

    return opts
  end,
}
