local cmp = require'cmp'

local entries = {}
local M = {}

local function locate_bib(lines)
	for _, line in ipairs(lines) do
    if string.find(line,'bibliography: (%g+)') then
      return string.match(line, 'bibliography: (%g+)')
    end
  end
end

local function parse_bib(filename)
  local file = io.open(filename, 'rb')
  local bibentries = file:read('*all')
  file:close()
  for bibentry in bibentries:gmatch('@.-\n}\n') do
    local entry = {}
    local title = bibentry:match('title%s*=%s*["{]*(.-)["}],?') or ''
    local author = bibentry:match('author%s*=%s*["{]*(.-)["}],?') or ''
    local year = bibentry:match('year%s*=%s*["{]?(%d+)["}]?,?') or ''
    entry.documentation = {
      kind = cmp.lsp.MarkupKind.Markdown,
      value = table.concat({'**'.. title.. '**', '', '*'..author..'*', year}, '\n')
    }
    entry.label = '@' .. bibentry:match('@%w+{(.-),')
    entry.kind = cmp.lsp.CompletionItemKind.Reference
    table.insert(entries, entry)
  end
end

local function parse_crossref(lines)
  local words = table.concat(lines)
  for ref in words:gmatch('{#(%a+:[%w]+)') do
    local entry = {}
    entry.label = '@' .. ref
    entry.kind = cmp.lsp.CompletionItemKind.Reference
    table.insert(entries, entry)
  end
end

function M.get_entries(lines)
  local location = locate_bib(lines)
  entries = {}

  if location and vim.fn.filereadable(location) == 1 then
    parse_bib(location)
  end
  parse_crossref(lines)

  return entries
end

return M
