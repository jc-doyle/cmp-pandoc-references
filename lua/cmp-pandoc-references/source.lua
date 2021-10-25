local refs = require 'cmp-pandoc-references.references'
local config = require'cmp-pandoc-references.config'

local source = {
  config = {}
}

source.new = function(overrides)
	local self = setmetatable({}, {__index = source})

  self.config = vim.tbl_deep_extend('force', config, overrides or {})

  return self
end

source.is_available = function(self)
	return vim.tbl_contains(self.config.filetypes, vim.bo.filetype)
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
