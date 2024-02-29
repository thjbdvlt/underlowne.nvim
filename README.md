undarlowne.nvim
minimal neovim plugin for markdown underlined titles, i.e:

```markdown
pretty subtitle
---------------

prettier title
==============

```

it adds an underline if there is none (non-title becomes title), and if there is one, it switches to the other one (change title style). (more exactly: it cycles to registered styles, and select the next one; but if there is only two styles, e.g. `---` and `===`, then "cycling through" and "switching" is pretty much the same).

example
-------

```markdown
magic place<cursor>
this magic place is cool.
```

will become:

```markdown
magic place
-----------

this magic place is cool.
```

which would become (if the function is used once again):

```markdown
magic place
===========

this magic place is cool.
```

usage and configuration
-----------------------

just require the plugin and map the function to anything (key, command).
i personally use `==` because in my practice of markdown writing, it is useless.

```lua
require('underlowne')
vim.api.nvim_set_keymap(
    "n",
    "==",
    ":lua Underlowne({'-', '='})<cr>",
    {noremap = true, silent = true}
)
```

any single character may be used as underlining chars, so it could also cycle (for example) through:

```
this     and this     and that
////     ........     ????????

and eventually this   or that
aaaaaaaaaaaaaaaaaaa   0000000
```

it works when the cursor is on the text to be underlined, or on the underlining line, i.e.:

```markdown
text as a title     |    text as a title
======<cursor>=     |    ---<cursor>----
```

if there are margins (trailing spaces), they are preserved, like in:

```markdown
             centered title
             ==============

and then a paragraph about singing birds.
```

there are actually two arrays of chars. the first one is the chars that must be _used_ as underlining chars, and the second one (which is optional) is the chars that must only be _recognized_ as underlining chars. so one can map something like:

```lua
vim.api.nvim_set_keymap(
    "n",
    "=-",
    ":lua Underlowne({'-'}, {'-', '=', '/'})<cr>",
    {noremap = true, silent = true}
)
vim.api.nvim_set_keymap(
    "n",
    "==",
    ":lua Underlowne({'='}, {'-', '=', '/'})<cr>",
    {noremap = true, silent = true}
)
```

using `=-`, lines underlines with `/` or `-` or `=` will be changed to `-`; and using `==`, lines underlines with `/`, `-` or `=` will be changed to `=` underlines.
