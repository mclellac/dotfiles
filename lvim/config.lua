-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
reload "user.plugins"
reload "user.options"
reload "user.nvimtree"



-- Install and setup Mason
require("mason").setup()

-- add `pyright` to `skipped_servers` list as we will use ruff/ruff_ls
-- perform :LvCacheReset after this has been set.
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })

