" ~/.vimrc

se nu
se ai
let mapleader = " "

" tabs and spaces handling
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Fonction pour commenter ou décommenter des lignes en fonction de l'extension du fichier (insensible à la casse)
function! ToggleComment()
  " Enregistrer la position du curseur
  let save_cursor = getpos(".")

  " Obtenir l'extension du fichier actuel en minuscules
  let file_extension = tolower(expand('%:e'))

  " Choix du prefix de commentaire en fonction du type de fichier
  if file_extension == "pl" || file_extension == "py" || file_extension == "ps1" || file_extension == "psm1" || file_extension == "sh"
    let comment_prefix = "#"
  elseif file_extension == "c" || file_extension == "h" || file_extension == "go"
    let comment_prefix = "//"
  endif

  " Obtenir le contenu de la ligne courante
  let line_content = getline('.')

  " Vérifier si la ligne courante correspond à l'expression rationnelle
  let regex_test_comment = '^\s*' . escape(comment_prefix, '\\/')
  if line_content =~ regex_test_comment
    execute 's/^\(\s*\)' . escape(comment_prefix, '\\/') . '/\1/'
  else
    execute 's/^/' . escape(comment_prefix, '\\/') . '/'
  endif
  
  " Rétablir la position du curseur
  call setpos(".", save_cursor)

endfunction
 
" Définit une fonction qui reformate les déclarations de variables avec un alignement
function! AlignVariableDeclarations()
  " Stocke la position actuelle du curseur
  let cursor_position = getpos('.')
  
  " Obtenir les lignes de la sélection visuelle
  let selected_lines = getline("'<", "'>")
  if empty(selected_lines)
    echo "Aucune sélection visuelle trouvée."
    return
  endif

  " Trouve la longueur maximale du côté gauche de l'égal dans la sélection
  let max_length = 0
  for line in selected_lines
    let parts = split(line, '=')
    let left_side = substitute(parts[0], '\s*$', '', '')
    let length = strdisplaywidth(left_side)
    if length > max_length
      let max_length = length
    endif
  endfor

  " Reformate les déclarations de variables dans la sélection
  for i in range(0, len(selected_lines) - 1)
    let line = selected_lines[i]
    if line =~ '='
      let parts = split(line, '=')
      let left_side = substitute(parts[0], '\s*$', '', '')
      let padding = repeat(' ', max_length - strdisplaywidth(left_side))
      let selected_lines[i] = left_side . padding . ' =' . parts[1]
    endif
  endfor

  " Remplace les lignes de la sélection dans le tampon
  call setline("'<", selected_lines)

  " Restaure la position du curseur
  call setpos('.', cursor_position)
endfunction

" Crée une commande personnalisée pour appeler la fonction sur la sélection visuelle
command! -range=% AlignVariablesVisual :<line1>,<line2>call AlignVariableDeclarations()

function! ToUpperCase()
  let line_text = getline('.')
  let col = col('.') - 1
  let word_end = col
  let word_start = col - 1

  while word_start >= 0 && line_text[word_start] =~ '\k'
    let word_start -= 1
  endwhile

  let word = line_text[word_start + 1 : word_end]
  let uppercase_word = toupper(word)

  if word != ''
    let save_cursor = getpos('.')
    let replacement = strpart(line_text, 0, word_start + 1) . uppercase_word . strpart(line_text, word_end + 1)
    call setline('.', replacement)
    call setpos('.', save_cursor)
    execute "normal! l"
  endif

endfunction

inoremap <C-U> <Esc>:call ToUpperCase()<CR>i



vnoremap <Leader>c :call ToggleComment()<CR>
vnoremap <Leader>a :call AlignVariableDeclarations()<CR>

au BufRead,BufNewFile *.cal set filetype=cal
syntax enable

