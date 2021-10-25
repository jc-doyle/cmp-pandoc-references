local source = require('cmp-pandoc-references.source')

local M = {}

M.setup = function(overrides)
  require('cmp').register_source('pandoc_references', source.new(overrides))
end

return M
