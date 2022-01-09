
let g:loaded_emphasiscursor = 1

if has('nvim')
	function! s:opt(w, h, r, c) abort
		return {
			\ 'relative': 'editor',
			\ 'width': a:w,
			\ 'height': a:h,
			\ 'row': a:r,
			\ 'col': a:c,
			\ 'focusable': 0,
			\ 'style': 'minimal'
			\ }
	endfunction

	function! EmphasisCursorStart() abort
		let inner_bnr = nvim_create_buf(v:false, v:true)
		let inner_winid = nvim_open_win(inner_bnr, 0, s:opt(1, 1, screenrow(), screencol()))
		call nvim_win_set_option(inner_winid, 'winhl', 'Normal:Normal')
		let bnr = nvim_create_buf(v:false, v:true)
		let winid = nvim_open_win(bnr, 0, s:opt(1, 1, screenrow(), screencol()))
		call nvim_win_set_option(winid, 'winhl', 'Normal:Search')
		call EmphasisCursor(10, bnr, winid, inner_bnr, inner_winid, 0)
	endfunction

	function! EmphasisCursor(i, bnr, winid, ibnr, iwinid, t) abort
		if 0 < a:i
			" outter
			let n = a:i % 2 ? 3 : 5
			let opts = s:opt(n, n, screenrow() - n / 2 - 1, screencol() - n / 2 - 1)
			call nvim_buf_set_lines(a:bnr, 0, -1, v:true, repeat([repeat(' ', n)], n))
			call nvim_win_set_config(a:winid, opts)
			" inner
			let n = a:i % 2 ? 1 : 3
			let iopts = s:opt(n, n, screenrow() - n / 2 - 1, screencol() - n / 2 - 1)
			call nvim_buf_set_lines(a:ibnr, 0, -1, v:true, repeat([repeat(' ', n)], n))
			call nvim_win_set_config(a:iwinid, iopts)
			redraw
			call timer_start(50, function('EmphasisCursor', [a:i - 1, a:bnr, a:winid, a:ibnr, a:iwinid]), {})
		else
			call nvim_win_close(a:winid, 0)
			call nvim_win_close(a:iwinid, 0)
		endif
	endfunction
else
	function! EmphasisCursorStart() abort
		call EmphasisCursor(10, popup_create([], {}), 0)
	endfunction

	function! EmphasisCursor(i, winid, t) abort
		if 0 < a:i
			let n = a:i % 2 ? 3 : 5
			call popup_settext(a:winid, repeat([repeat(' ', n)], n))
			call popup_setoptions(a:winid, {
				\ 'line': 'cursor-' .. (n / 2),
				\ 'col':  'cursor-' .. (n / 2),
				\ 'mask': a:i % 2 ? [] : [[2, 4, 2, 4]],
				\ 'highlight':  'Search',
				\ })
			call win_execute(a:winid, 'redraw')
			call timer_start(50, function('EmphasisCursor', [a:i - 1, a:winid]), {})
		else
			call popup_close(a:winid)
		endif
	endfunction
endif

command! -bar -nargs=0 EmphasisCursor :call EmphasisCursorStart()

