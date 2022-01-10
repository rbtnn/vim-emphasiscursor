
let g:loaded_emphasiscursor = 1

let s:COUNT = 10
let s:MSEC = 50
let s:ZINDEX = 100
let s:HIGHLIGHT = 'Search'

if has('nvim')
	function! s:pos() abort
		let winid = win_getid()
		if win_gettype(winid) == 'popup'
			let info = get(getwininfo(winid), 0, {})
			let num = &number ? &numberwidth : 0
			let border_size = !empty(get(nvim_win_get_config(winid), 'border', [])) ? 1 : 0
			return [
				\ info['winrow'] + line('.') - line('w0') + border_size,
				\ info['wincol'] + col('.') - 1 + num + border_size]
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

	function! s:emphasiscursor_start() abort
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
	function! s:emphasiscursor_start() abort
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

command! -bar -nargs=0 EmphasisCursor :call <SID>emphasiscursor_start()

