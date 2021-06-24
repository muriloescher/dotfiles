set encoding=utf-8
set t_Co=256
set background=dark
colorscheme slate
syntax on 
set number
set relativenumber
filetype indent plugin on
set autoindent
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set backspace=indent,eol,start
set fo=tcroq
set wrap 
set textwidth=100


" Barra na parte inferior
set laststatus=2
"set laststatus=%f

" Teste de mudança do ESC
inoremap kj <esc>
cnoremap kj <C-C>


" Compila/Executa arquivo com base na extensão dele
let extension = expand('%:e')
if extension == "c"
    nnoremap <F7> :w<cr> :!gcc % -o %< -lm<cr> :!./%<<cr>
elseif extension == "tex"
    set autoindent!
    set textwidth=100
    nnoremap <F7> :w<cr> :!pdflatex %<cr> :!latexmk -c<cr>
    nnoremap ,eq i\begin{equation*}<cr>\end{equation*}<esc>k>j..o
    nnoremap ,al i\begin{align*}<cr>\end{align*}<esc>k>j..o
    set relativenumber
    set tabstop=2
    set softtabstop=2
    set shiftwidth=2
elseif extension == "py"
    nnoremap <F7> :w<cr> :!python3 %<cr>
elseif extension == "cpp"
    nnoremap <F7> :w<cr> :!g++ -std=c++11 -O2 -Wall % -o %<<cr> :!./%<<cr>
endif


" Mapeia ,c para um modelo de programa .c
nnoremap ,c :-1read $HOME/.vim/.skeleton.c<CR>4j4li


" Automaticamente lê um modelo .c para novos arquivos criados
autocmd BufNewFile *.c -1read $HOME/.vim/.skeleton.c | execute "normal 4j4l" | execute "startinsert" 
" Automaticamente lê um modelo .tex para novos arquivos criados
autocmd BufNewFile ILC_Lista* -1read $HOME/.vim/.listailc.tex | execute "normal 8j12l" | execute "startinsert" 
" Automaticamente lê um modelo .cpp para novos arquivos criados
autocmd BufNewFile *.cpp -1read $HOME/.vim/.cp.cpp | execute "normal 6j4l" | execute "startinsert" 

" Ps = 0  -> blinking block.
" Ps = 1  -> blinking block (default).
" Ps = 2  -> steady block.
" Ps = 3  -> blinking underline.
" Ps = 4  -> steady underline.
" Ps = 5  -> blinking bar (xterm).
" Ps = 6  -> steady bar (xterm).

" vim cursor escape codes for the terminal emulator
" INSERT (&t_SI)  - vertical bar (I-beam)
" REPLACE (&t_SR) - underscore
" VISUAL (&t_EI)  - block
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"
" 
