" General

imap jj <Esc>
set number
set colorcolumn=80
autocmd BufWritePost *.go silent! execute "!gofmt -s -w <afile> >/dev/null 2>&1" | redraw!
autocmd BufWritePost *.py silent! execute "!black <afile> >/dev/null 2>&1" | redraw!

" Override bug until merged: https://github.com/amix/vimrc/pull/621
let g:snipMate = { 'snippet_version' : 1 }

" Plugins

" NERD Tree
" Toggle NERD Tree
:nnoremap <C-g> :NERDTreeToggle<CR>
" Quit NERDTree if it is the last buffer
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Open on the left side by default
let g:NERDTreeWinPos = "left"

" YCM
" Make YCM go away when done with it
let g:ycm_autoclose_preview_window_after_completion=1
" Smart go to
map <leader>g :YcmCompleter GoTo<CR>
map <leader>d :YcmCompleter GetDoc<CR>

" Colorscheme
set t_Co=256
set term=xterm-256color
