set number          " Turn line numbers on.
syntax on           " Turn syntax highlighting on.
filetype on         " Enable type file detection. Vim will be able to try to detect the type of file in use.
set nocompatible    " Disable compatibility with vi which can cause unexpected issues.
set hlsearch        " highlight all search results
set incsearch       " incremental search results while typing
set belloff=all     " disables DING and flash

" This unsets the 'last search pattern' register by hitting return
nnoremap <silent> <esc> :noh<return><esc>

