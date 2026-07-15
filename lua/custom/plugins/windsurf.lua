return {
    "Exafunction/windsurf.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("codeium").setup({
            -- The default portal (codeium.com) redirects to the Devin
            -- dashboard and drops the auth parameters, so :Codeium Auth
            -- never shows the token page. Point at windsurf.com directly.
            api = {
                portal_url = "windsurf.com",
            },
        })
    end,
}
