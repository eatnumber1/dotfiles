syntax region liquidHighlightGraphviz start="{%\s\+graphviz\s\+%}" end="{%\s\+endgraphviz\s\+%}" keepend contains=@liquidHighlightdot,@NoSpell
syntax keyword liquidKeyword graphviz nextgroup=liquidHighlightGraphviz skipwhite contained
syntax keyword liquidKeyword endgraphviz contained
