return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = false,
  opts = {
    signs = true,
    sign_priority = 60,
  },
  config = function(_, opts)
    local todo = require("todo-comments")
    todo.setup(opts)

    vim.keymap.set("n", "]t", todo.jump_next, { desc = "Next todo comment" })
    vim.keymap.set("n", "[t", todo.jump_prev, { desc = "Previous todo comment" })
    vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<CR>", { desc = "Find TODOs" })
  end,
}
