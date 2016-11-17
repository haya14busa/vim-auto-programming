# vim-auto-programming

vim-auto-programming provide statistical whole lines completions for git project.
It's a Vim port implementation of [hitode909/atom-auto-programming](https://github.com/hitode909/atom-auto-programming).

It's like `i_CTRL-X_CTRL-L` but powerd by `git grep`.

![demo](https://raw.githubusercontent.com/haya14busa/i/41a4dddba9d6bb00654c506cc84455d756e8cd31/vim-auto-programming/anim.gif)

## How To Use

```vim
set completefunc=autoprogramming#complete
```

Write some code and run `<C-x><C-u>` or something to invoke `autoprogramming#complete` manually.
You will get candidates of next line of the code.

For example, when you type `impo`, the code you want to get is `import (`, and you might want to insert next line as `"fmt"`.

## Requirements
- Only git projects are supported.

