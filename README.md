# vim-screenpaste
Vim plugin that lets you copy and paste to a different GNU screen window.

- Works only within a GNU screen session. (Detects $STY)
- For **interactive development**, similar to Jupyter Notebook. You can paste your code on a bash shell or an ipython interpreter.
- Detects vim/neovim and ipython running, and paste within an appropriate paste mode.


Note that it:
- Uses many system calls. Tested mainly on Ubuntu and Windows WSL.

## Installation

Use your favourite plugin manager. I use [vim-plug](
```vimscript
Plug 'junegunn/vim-easy-align'
```
