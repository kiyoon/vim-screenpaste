" screenpaste.vim - Paste your code to another GNU screen window.
" Maintainer:   Kiyoon Kim <https://kiyoon.kim/>
" Version:      1.0
"
" Press <num>- to copy and paste lines to screen window <num>.
" For example, 1- will paste selection (or current line)
" to window 1 on GNU Screen.
" If number not specified, then it will paste to window 0.
" Use <leader>- (or \-) to copy to a window named `-console`.
" Use _ instead of - to copy without detecting the window.
" Use <C-_> to copy into the screen buffer. You can paste using C-a ].

if exists('g:loaded_gnuscreenpaste') || &compatible
  finish
else
  let g:loaded_gnuscreenpaste = 'yes'
endif

" Commands that only work in a GNU Screen session.
if $STY
	let plugin_dir = fnamemodify(fnamemodify(resolve(expand('<sfile>:p')), ':h'), ':h')

	function! DetectRunningProgram(windowIdx)
		" Detects if VIM or iPython is running on a Screen window.
		" Returns: 'vim', 'ipython', or 'others'
		"
		let runningProgram = system('bash ''' . g:plugin_dir . '/scripts/display_screen_window_commands.sh'' | grep ''^' . a:windowIdx . ' '' | awk ''{for(i=2;i<=NF;++i)printf $i" "}'' ')
		if empty(runningProgram)
			return '-bash'
		else
			let programName = fnamemodify(split(runningProgram, ' ')[0], ':t')
			if programName ==# 'vi' || programName ==# 'vim' || programName ==# 'nvim'
				return 'vim'
			elseif stridx(runningProgram, '/ipython ') > 0
				return 'ipython'
			endif
		endif
		return 'others'
	endfunction

	function! ScreenAddBuffer(content)
		" Add content to the GNU Screen buffer.
		" Paste using C-a ]
		"
		let tempname = tempname()
		call writefile(split(a:content, "\n"), tempname, 'b')

		" msgwait: Suppress messages like 'Slurped 300 characters to buffer'
		let screenMsgWaitCommand = 'screen -X msgwait 0'
		let screenRegCommand = 'screen -X readbuf ' . tempname
		let screenMsgWaitUndoCommand = 'screen -X msgwait 5'
		call system(screenMsgWaitCommand)
		call system(screenRegCommand)
		call system(screenMsgWaitUndoCommand)
	endfunction

	function! ScreenPaste(pasteWindow, content, addNewLine, pasteTo)
"		function! EscapeForScreenStuff(content)
"			" Escape string for GNU Screen (stuff).
"			" By doing this, Screen stuff will be operating the literal string, not evaluating environment variables.
"			" For example, without this, $HOME will be pasted as /home/user.
"			" \ -> \\
"			" $ -> \$
"			" ^ -> \^
"			" ' -> '"'"'
"			" newline -> ^@ -> \n (literal string)
"			" no space escaping
"			let strsub = substitute(a:content,'\\','\\\\','g')
"			let strsub = substitute(strsub,'\$','\\$','g')
"			let strsub = substitute(strsub,'\^','\\^','g')
"			let strsub = substitute(strsub,'''','''"''"''','g')
"			let strsub = substitute(strtrans(strsub),'\^@','\\n','g')
"			return strsub
"		endfunction
"		let escapedContent = EscapeForScreenStuff(a:content)
"		let newlinestr = a:addNewLine ? "\n" : ''
"		let screenPasteCommand = 'screen -p ' . a:pasteWindow . ' -X stuff ''' . escapedContent . newlinestr . ''''

		let tempname = tempname()
		call writefile(split(a:content, "\n"), tempname, 'b')


		" msgwait: Suppress messages like 'Slurped 300 characters to buffer'
		let screenMsgWaitCommand = 'screen -X msgwait 0'
		let screenRegCommand = 'screen -X readreg s ' . tempname
		let screenMsgWaitUndoCommand = 'screen -X msgwait 5'
		let screenPasteCommand = 'screen -p ' . a:pasteWindow . ' -X paste s'
		call system(screenMsgWaitCommand)
		call system(screenRegCommand)
		if a:pasteTo ==? 'vim'
			" ^[ => Ctrl+[ = ESC
			" Enter paste mode
			call system('screen -p ' . a:pasteWindow . ' -X stuff ''^[:set paste\no''')
		elseif a:pasteTo ==? 'ipython'
			call system('screen -p ' . a:pasteWindow . ' -X stuff ''^U%cpaste\n''')
			" Without sleep, sometimes you don't see what's being pasted.
			execute 'sleep 100m'
		endif
		call system(screenPasteCommand)
		call system(screenMsgWaitUndoCommand)

		if a:addNewLine == 1
			" vim already adds line by typing 'o'
			if a:pasteTo != 'vim'
				call system('screen -p ' . a:pasteWindow . ' -X stuff ''\n''')
			endif
		endif
		echom 'Paste to Screen window ' . a:pasteWindow . ' (' . a:pasteTo . ')'
		redraw
		if a:pasteTo ==? 'vim'
			" ^[ => Ctrl+[ = ESC
			" Exit paste mode and force redraw (need to redraw if pasting to same screen)
			call system('screen -p ' . a:pasteWindow . ' -X stuff ''^[:set nopaste\n:redraw!\n''')
		elseif a:pasteTo ==? 'ipython'
			execute 'sleep 100m'
			call system('screen -p ' . a:pasteWindow . ' -X stuff ''\n--\n''')
		endif
		call delete(tempname)
	endfunction

	" 1. save count to pasteWindow
	" 2. yank using @s register.
	" 3. detect if vim or ipython is running
	" 4. execute screen command.
	nnoremap <silent> - :<C-U>let pasteWindow=v:count<CR>"syy:call ScreenPaste(pasteWindow, @s, 1, DetectRunningProgram(pasteWindow))<CR>
	vnoremap <silent> - :<C-U>let pasteWindow=v:count<CR>gv"sy:call ScreenPaste(pasteWindow, @s, 1, DetectRunningProgram(pasteWindow))<CR>
	" pasting to window 0 is not 0; but \;. Explicit separate command because v:count is 0 for no count, and also 0 is a command that moves the cursor.
	nnoremap <silent> <leader>- "syy:<C-U>call ScreenPaste('-console', @s, 1, DetectRunningProgram('-console'))<CR>
	vnoremap <silent> <leader>- "sy:<C-U>call ScreenPaste('-console', @s, 1, DetectRunningProgram('-console'))<CR>
	"""""""""""""""
	" Same thing but <num>_ to paste without detecting running programs and without the return at the end.
	nnoremap <silent> _ :<C-U>let pasteWindow=v:count<CR>"syy:call ScreenPaste(pasteWindow, @s, 0, 'nodetect')<CR>
	vnoremap <silent> _ :<C-U>let pasteWindow=v:count<CR>gv"sy:call ScreenPaste(pasteWindow, @s, 0, 'nodetect')<CR>
	nnoremap <silent> <leader>_ "syy:<C-U>call ScreenPaste('-console', @s, 0, 'nodetect')<CR>
	vnoremap <silent> <leader>_ "sy:<C-U>call ScreenPaste('-console', @s, 0, 'nodetect')<CR>

	"""""""""""""""
	" Copy to Screen buffer
	nnoremap <silent> <C-_> :<C-U>let pasteWindow=v:count<CR>"syy:call ScreenAddBuffer(@s)<CR>
	vnoremap <silent> <C-_> :<C-U>let pasteWindow=v:count<CR>gv"sy:call ScreenAddBuffer(@s)<CR>
	""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
endif
