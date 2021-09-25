# cmp-pandoc-references

A source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp), providing completion for bibliography, reference and cross-ref items.

## Demo
![cmp-pandoc-references](https://user-images.githubusercontent.com/59124867/134782887-33872ae0-a23e-4f5b-99cd-74c3b0e6f497.gif)

Note I have overridden the `ItemKinds`, they are set to `cmp.lsp.CompletionItemKind.Reference` by default.

## Installation & Usage

Assuming Packer:

``` lua
use({
  "hrsh7th/nvim-cmp",
  requires = {
    { "jc-doyle/cmp-pandoc-references" }
  }
})
```

Add the source:

``` lua
require('cmp').setup {
  sources = {
    { name = 'pandoc_references' }
  }
}
```

## Explanation & Limitations

This source parses and validates the `bibliography: [your/bib/location.bib]` YAML metadata field, to determine the destination of the file (see [Pandoc](https://pandoc.org/MANUAL.html#specifying-bibliographic-data)). If it is not included (or you specify it through a command-line argument), no bibliography completion items will be found.

(I use the metadata block to reference bibliographies, if you'd like automatic scanning of directories/sub-directories, feel free to submit a PR)



