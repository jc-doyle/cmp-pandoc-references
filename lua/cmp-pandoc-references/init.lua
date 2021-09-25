local source = {}
local refs = require 'cmp-pandoc-references.references'

source.new = function()
	return setmetatable({}, {__index = source})
end

-- Add another filetype if needed
source.is_available = function()
	return vim.o.filetype == 'pandoc' or vim.o.filetype == 'markdown'
end

source.get_keyword_pattern = function()
	return '[@][^[:blank:]]*'
end

source.complete = function(self, request, callback)
  local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
  local entries = refs.get_entries(lines)

  if entries then
    self.items = entries
    callback(self.items)
  end
end

return source
