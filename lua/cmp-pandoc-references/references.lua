local cmp = require 'cmp'

local entries = {}
local M = {}

-- (Crudely) Locates the bibliography
local function locate_bib(lines)
	for _, line in ipairs(lines) do
		location = string.match(line, 'bibliography: (%g+)')
		if location then
			return location
		end
	end
end

-- Remove newline & excessive whitespace
local function clean(text)
  if text then
    text = text:gsub('\n', ' ')
    return text:gsub('%s%s+', ' ')
  else
    return text
  end
end

-- Parses the .bib file, formatting the completion item
-- Adapted from http://rgieseke.github.io/ta-bibtex/
local function parse_bib(filename)
	local file = io.open(filename, 'rb')
	local bibentries = file:read('*all')
	file:close()
	for bibentry in bibentries:gmatch('@.-\n}\n') do
		local entry = {}

		local title = clean(bibentry:match('title%s*=%s*["{]*(.-)["}],?')) or ''
		local author = clean(bibentry:match('author%s*=%s*["{]*(.-)["}],?')) or ''
		local year = bibentry:match('year%s*=%s*["{]?(%d+)["}]?,?') or ''

		local doc = {'**' .. title .. '**', '', '*' .. author .. '*', year}

		entry.documentation = {
			kind = cmp.lsp.MarkupKind.Markdown,
			value = table.concat(doc, '\n')
		}
		entry.label = '@' .. bibentry:match('@%w+{(.-),')
		entry.kind = cmp.lsp.CompletionItemKind.Reference

		table.insert(entries, entry)
	end
end

-- Parses the references in the current file, formatting for completion
local function parse_ref(lines)
	local words = table.concat(lines)
	for ref in words:gmatch('{#(%a+[:-][%w_-]+)') do
		local entry = {}
		entry.label = '@' .. ref
		entry.kind = cmp.lsp.CompletionItemKind.Reference
		table.insert(entries, entry)
	end
end

-- Returns the entries as a table, clearing entries beforehand
function M.get_entries(lines)
	local location = locate_bib(lines)
	entries = {}

	if location and vim.fn.filereadable(location) == 1 then
		parse_bib(location)
	end
	parse_ref(lines)

	return entries
end

return M
