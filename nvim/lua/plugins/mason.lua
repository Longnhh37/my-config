return {
    "mason-org/mason.nvim",
    lazy = false,
    build = ":MasonUpdate",
    opts = { ui = { border = "rounded" } },
    config = function(_, opts)
        require("mason").setup(opts)
    end
}
