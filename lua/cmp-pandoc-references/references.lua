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
    -- Remove { or } tokens inserted by Zotero
    text = text:gsub('[{}]+', '')
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

    -- regex courtesy from /aspeddro/cmp-pandoc.nvim
    local title = bibentry:match("title%s*=%s*[{]*(.-)[}],") or "***NOTITLE***"
    local author = bibentry:match('[ae][ud][ti][ht][o][r]%s*=%s*["{]*(.-)["}],?') or "***NOAUTHOR***"
    local year = bibentry:match('[yd][ea][at][re]%s*=%s*["{]?(%d+)["}]?,?') or "***NODATE***"

		local doc = {
      '**' .. clean(title) .. '**', 
      '*' .. clean(author) .. '*', 
      year
    }

		entry.documentation = {
			kind = cmp.lsp.MarkupKind.Markdown,
			value = table.concat(doc, '\n\n')
		}
		entry.label = '@' .. bibentry:match('@%w+{(.-),')
		entry.kind = cmp.lsp.CompletionItemKind.Reference

		table.insert(entries, entry)
	end
end

local function latex_preview(str, sep)
  local nabla_avilable, _ = pcall(require, "nabla")

  if not nabla_avilable then
    return str
  end
  
  -- undo table -> string with separator
  str_table = {}
  for match in str:gmatch("[^" .. sep .. "]+") do
    str = match
    table.insert(str_table, match)
  end

  str_table = require("nabla").gen_drawing(str_table)

  if str_table == 0 then
    return str
  end

  return table.concat(str_table, "\n")
end

-- Parses the references in the current file, formatting for completion
local function parse_ref(lines)
	local buffer = table.concat(lines, "\n")

  reference = '{#(%a+:[%w_-]+)}'
  matchers = {
    equation = { title = "**Equation**", regex = "%$%$\n?(.-)\n?%$%$" },
    listing = { title = "**Listing**", regex = "```.-```\n\n: (.-) "},
    table = { title = "**Table**", regex = "|.-|.-\n\n: (.-) " },
    figure = { title = "**Figure**", regex = "(!%[.-%])%(?.-%)?"}
  }

  for type, matcher in pairs(matchers) do
    local num = 0

    for desc, ref in buffer:gmatch(matcher.regex .. reference) do
      num = num + 1
      local entry = {}

      if type == "equation" then
        desc = latex_preview(desc, "\n")
      end

      entry.documentation = {
        kind = cmp.lsp.MarkupKind.Markdown,

        value = matcher.title .. " **(" ..  num .. ")**" .. "\n\n" .. desc
      }
      entry.label = '@' .. ref
      entry.kind = cmp.lsp.CompletionItemKind.Reference

      table.insert(entries, entry)
    end
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
