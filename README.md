# vim-screenpaste
Vim plugin that lets you copy and paste to a different GNU screen window.

![screenpaste-demo](https://user-images.githubusercontent.com/12980409/199625262-e4e6b901-11e8-47b9-8b30-91809281f6be.gif)

- Works only within a GNU screen session. (Detects $STY)
- For **interactive development**, similar to Jupyter Notebook. You can paste your code on a bash shell or an ipython interpreter.
- Detects vim/neovim and ipython running, and paste within an appropriate paste mode.


Note that it:
- Uses many system calls. Tested mainly on Ubuntu and Windows WSL.


## Features
- `[num]-`: Paste line or selection to Screen window \<num\>. If [num] is not specified, paste to window 0. Detect if Vim or iPython is running on the window, and paste accordingly.
- `\-`: Paste to window named -console.
- `[num]_`, `\_`: Same as `-` but does not detect program nor add newline at the end.
- `<C-_>`: Copy to Screen paste buffer. You can paste it with \<C-a\> \] anywhere.


## Installation

Use your favourite plugin manager. I use [vim-plug](https://github.com/junegunn/vim-plug).
```vim
Plug 'kiyoon/vim-screenpaste'
```
