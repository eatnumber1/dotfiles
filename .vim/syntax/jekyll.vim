if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

syntax include @Yaml syntax/yaml.vim
syntax region yamlFrontmatter start=/\%^---$/ end=/^---$/ keepend contains=@Yaml,@Spell
unlet! b:current_syntax

"runtime! syntax/markdown.vim
"unlet! b:current_syntax

syn keyword liquidSpecial date_to_xmlschema date_to_string date_to_long_string xml_escape cgi_escape number_of_words array_to_sentence_string textilize markdownify
syn keyword liquidKeyword include

" Liquid includes html
runtime! syntax/liquid.vim
unlet! b:current_syntax

syn region liquidHighlight start="{%\s\+highlight\s.\+%}" end="{%\s\+endhighlight\s\+%}"
hi link liquidHighlight Comment

let b:current_syntax='jekyll'
