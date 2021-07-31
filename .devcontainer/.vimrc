" Indent correctly
filetype plugin indent on

" Automatically close braces
inoremap {<CR> {<CR>}<Esc>ko

" Remap keys
imap jj <Esc>
let mapleader = ","
map <leader>g :GoDef<CR>
map <leader>d :GoDoc<CR>

" Line numbers
set number

" Width marker
set colorcolumn=80

" Background color
set background=dark

" Goimports for saving
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"

" Highlight go syntax
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1

" Automatically close autocomplete
augroup completion_preview_close
 autocmd!
 autocmd CompleteDone * if !&previewwindow && &completeopt =~ 'preview' | silent! pclose | endif
augroup END
