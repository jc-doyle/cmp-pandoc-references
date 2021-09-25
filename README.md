# cmp-pandoc-references

A source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp), providing completion for bibliography and cross-ref items.

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
    { name = 'pandoc-references' }
  }
}
```

## Explanation & Limitations

This source parses and validates the `bibliography: [your/bib/location.bib]` YAML metadata field, to determine the destination of the file (see [Pandoc](https://pandoc.org/MANUAL.html#specifying-bibliographic-data)). If it is not included (or you specify it through a command-line argument), no bibliography completion items will be found.

(I use the metadata block to reference bibliographies, if you'd like automatic scanning of directories/sub-directories, feel free to submit a PR)



