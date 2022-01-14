
let g:loaded_emphasiscursor = 1

let s:OPT_COUNT = '-count='
let s:OPT_MSEC = '-msec='
let s:OPT_ZINDEX = '-zindex='
let s:OPT_HIGHLIGHT = '-highlight='

function! s:init(q_args) abort
	let s:COUNT = 10
	let s:MSEC = 50
	let s:ZINDEX = 100
	let s:HIGHLIGHT = 'Search'
	for x in split(a:q_args, '\s\+')
		if x =~# '^' .. s:OPT_COUNT .. '\S\+$'
			let s:COUNT = matchstr(x, '=\zs\S\+$')
		elseif x =~# '^' .. s:OPT_MSEC .. '\S\+$'
			let s:MSEC = matchstr(x, '=\zs\S\+$')
		elseif x =~# '^' .. s:OPT_ZINDEX .. '\S\+$'
			let s:ZINDEX = matchstr(x, '=\zs\S\+$')
		elseif x =~# '^' .. s:OPT_HIGHLIGHT .. '\S\+$'
			let s:HIGHLIGHT = matchstr(x, '=\zs\S\+$')
		endif
	endfor
endfunction

if has('nvim')
	function! s:border_itmesize(x) abort
		echo a:x
		if (type('') == type(a:x)) && !empty(a:x)
			return 1
		elseif (type([]) == type(a:x)) && !empty(get(a:x, 0, ''))
			return 1
		else
			return 0
		endif
	endfunction

	function! s:pos() abort
		let winid = win_getid()
		if win_gettype(winid) == 'popup'
			let info = get(getwininfo(winid), 0, {})
			let num = &number ? &numberwidth : 0
			let border = get(nvim_win_get_config(winid), 'border', [])
			let border_top = 0
			let border_left = 0
			if type('') == type(border)
				"call nvim_open_win(nvim_create_buf(v:false, v:true), 0, { 'relative': 'editor', 'width': 5, 'height': 5, 'row': 5, 'col': 5, 'border': 'single', })
				let border_top = s:border_itmesize(border)
				let border_left = s:border_itmesize(border)
			elseif type([]) == type(border)
				if 1 == len(border)
					"call nvim_open_win(nvim_create_buf(v:false, v:true), 0, { 'relative': 'editor', 'width': 5, 'height': 5, 'row': 5, 'col': 5, 'border': ["*"], })
					let border_top = s:border_itmesize(border[0])
					let border_left = s:border_itmesize(border[0])
				elseif 2 == len(border)
					"call nvim_open_win(nvim_create_buf(v:false, v:true), 0, { 'relative': 'editor', 'width': 5, 'height': 5, 'row': 5, 'col': 5, 'border': ['1', '2'], })
					let border_top = s:border_itmesize(border[1])
					let border_left = s:border_itmesize(border[1])
				elseif 4 == len(border)
					"call nvim_open_win(nvim_create_buf(v:false, v:true), 0, { 'relative': 'editor', 'width': 5, 'height': 5, 'row': 5, 'col': 5, 'border': ['1', '2', '3', '4'], })
					let border_top = s:border_itmesize(border[1])
					let border_left = s:border_itmesize(border[3])
				elseif 8 == len(border)
					"call nvim_open_win(nvim_create_buf(v:false, v:true), 0, { 'relative': 'editor', 'width': 5, 'height': 5, 'row': 5, 'col': 5, 'border': ['1', '2', '3', '4','5', '6', '7', '8'], })
					let border_top = s:border_itmesize(border[1])
					let border_left = s:border_itmesize(border[7])
				endif
			endif
			return [
				\ info['winrow'] + line('.') - line('w0') + border_top,
				\ info['wincol'] + col('.') - 1 + num + border_left]
		else
			return [screenrow(), screencol()]
		endif
	endfunction

	function! s:opt(w, h, r, c) abort
		return {
			\ 'relative': 'editor',
			\ 'width': a:w,
			\ 'height': a:h,
			\ 'row': a:r,
			\ 'col': a:c,
			\ 'focusable': 0,
			\ 'zindex': s:ZINDEX,
			\ 'style': 'minimal'
			\ }
	endfunction

	function! s:emphasiscursor_start(q_args) abort
		call s:init(a:q_args)
		let pos = s:pos()
		" inner
		let inner_bnr = nvim_create_buf(v:false, v:true)
		let inner_winid = nvim_open_win(inner_bnr, 0, s:opt(1, 1, pos[0], pos[1]))
		call nvim_win_set_option(inner_winid, 'winhl', 'Normal:Normal')
		" outter
		let bnr = nvim_create_buf(v:false, v:true)
		let winid = nvim_open_win(bnr, 0, s:opt(1, 1, pos[0], pos[1]))
		call nvim_win_set_option(winid, 'winhl', 'Normal:' .. s:HIGHLIGHT)
		call s:emphasiscursor_inner(s:COUNT, bnr, winid, inner_bnr, inner_winid, 0)
	endfunction

	function! s:emphasiscursor_inner(i, bnr, winid, ibnr, iwinid, t) abort
		if 0 < a:i
			let pos = s:pos()
			" outter
			let n = a:i % 2 ? 3 : 5
			let opts = s:opt(n, n, pos[0] - n / 2 - 1, pos[1] - n / 2 - 1)
			call nvim_buf_set_lines(a:bnr, 0, -1, v:true, repeat([repeat(' ', n)], n))
			call nvim_win_set_config(a:winid, opts)
			" inner
			let n = a:i % 2 ? 1 : 3
			let iopts = s:opt(n, n, pos[0] - n / 2 - 1, pos[1] - n / 2 - 1)
			call nvim_buf_set_lines(a:ibnr, 0, -1, v:true, repeat([repeat(' ', n)], n))
			call nvim_win_set_config(a:iwinid, iopts)
			call win_execute(a:iwinid, 'redraw')
			call win_execute(a:winid, 'redraw')
			call timer_start(s:MSEC, function('s:emphasiscursor_inner', [a:i - 1, a:bnr, a:winid, a:ibnr, a:iwinid]), {})
		else
			call nvim_win_close(a:winid, 0)
			call nvim_win_close(a:iwinid, 0)
		endif
	endfunction
else
	function! s:emphasiscursor_start(q_args) abort
		call s:init(a:q_args)
		call s:emphasiscursor_inner(s:COUNT, popup_create([], {}), 0)
	endfunction

	function! s:emphasiscursor_inner(i, winid, t) abort
		if 0 < a:i
			let n = a:i % 2 ? 3 : 5
			call popup_settext(a:winid, repeat([repeat(' ', n)], n))
			call popup_setoptions(a:winid, {
				\ 'line': 'cursor-' .. (n / 2),
				\ 'col':  'cursor-' .. (n / 2),
				\ 'mask': a:i % 2 ? [] : [[2, 4, 2, 4]],
				\ 'highlight':  s:HIGHLIGHT,
				\ 'zindex': s:ZINDEX,
				\ })
			call win_execute(a:winid, 'redraw')
			call timer_start(s:MSEC, function('s:emphasiscursor_inner', [a:i - 1, a:winid]), {})
		else
			call popup_close(a:winid)
		endif
	endfunction
endif

function! EmphasisCursorComp(ArgLead, CmdLine, CursorPos) abort
	let xs = []
	for x in [s:OPT_COUNT, s:OPT_MSEC, s:OPT_ZINDEX, s:OPT_HIGHLIGHT]
		if -1 == match(a:CmdLine, x)
			let xs += [x]
		endif
	endfor
	return filter(xs, { i,x -> -1 != match(x, a:ArgLead) })
endfunction

command! -nargs=* -complete=customlist,EmphasisCursorComp EmphasisCursor :call <SID>emphasiscursor_start(<q-args>)

