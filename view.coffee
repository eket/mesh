SIO = ':4567'
_polys =
  [[0, 1, 2],
  [1, 2, 3],
  [2, 3, 4],
  [3, 4, 5],
  [4, 5, 6],
  [4, 6, 7],
  [6, 7, 8],
  [0, 7, 8],
  [0, 2, 7],
  [2, 4, 7]]
v.push (one.color '#f00') for v in _polys

_points =
[{"x":0.28330893118594436,"y":0.006510416666666667},{"x":0.7379209370424598,"y":0.033854166666666664},{"x":0.6610541727672035,"y":0.31640625},{"x":0.9238653001464129,"y":0.5},{"x":0.5863836017569546,"y":0.8216145833333334},{"x":0.691800878477306,"y":0.9283854166666666},{"x":0.28038067349926793,"y":0.90234375},{"x":0.26281112737920936,"y":0.46484375},{"x":0.09370424597364568,"y":0.4453125}]

___ = (x) -> console.log x

_sock = null
_canvas = null
_context = null
[_w, _h] = [0,0]

_dump = -> JSON.stringify ({x:p.x, y:p.y} for p in _points)

_send = (i) ->
  ___ ">>#{i}"
  _sock.emit 'e', i

_send_fade_out = (i,d) ->
  ___ ">>#{i} fade out"
  _sock.emit 'fade_out', [i,d]

_init = ->
  ___ 'initialize canvas'
  window.addEventListener 'resize', _resize, no
  _canvas = document.getElementById 'mesh_canvas'
  _context = _canvas.getContext '2d'
  _resize()

  #_add_event_listener _canvas, 'down', _on_down_edit
  #_add_event_listener _canvas, 'up', _on_up_edit
  #_add_event_listener _canvas, 'move', _on_move_edit

  _add_event_listener _canvas, 'move', _.throttle _on_move_hl, 50
  _add_event_listener _canvas, 'down', _on_down_fade

  ___ 'initialize socket'
  _sock = io.connect SIO
  _sock.on 'connect', ->
    ___ 'connected'
    _sock.on 'u', (d) ->
      _polys[i][3] = one.color p for p,i in d
    _sock.on 'fade_out', (d) ->
      _fade_out d[0], d[1]

  _loop _context

_fade_out = (i, duration) ->
  _polys[i][4] = [Date.now(), duration, (v,t) ->
    if 0<t<1 then v[3].lightness v[3].lightness()* (0.4-t) else v[3]]

_loop = (__) ->
  __.clearRect 0, 0, _w, _h
  #__.strokeStyle = (one.color '#00f').css()
  #__.lineWidth = 2
  now = Date.now()
  for v, i in _polys
    [sh_start, sh_duration, sh_fun] = v[4] if v[4]?
    __.fillStyle = (if sh_fun? then (sh_fun v, (now-sh_start)/sh_duration) else v[3]).css()
    __.beginPath()
    __.moveTo _w*_points[v[0]].x, _h*_points[v[0]].y
    __.lineTo _w*_points[v[1]].x, _h*_points[v[1]].y
    __.lineTo _w*_points[v[2]].x, _h*_points[v[2]].y
    __.lineTo _w*_points[v[0]].x, _h*_points[v[0]].y
    __.fill()
    #__.stroke()

  #for v,i in _points
    #__.font = 'normal 20px monospace'
    #__.fillStyle = (one.color '#fff').css()
    #__.fillText i, _w*v.x, _h*v.y

  window.webkitRequestAnimationFrame -> _loop __

_on_down_fade = (e) ->
  [x, y] = [(_get_x e), (_get_y e)]
  if (p=_find_poly x, y)?
    _send_fade_out (_polys.indexOf p), 5000


_on_move_hl = (e) ->
  [x, y] = [(_get_x e), (_get_y e)]
  if p = _find_poly x, y
    _send _polys.indexOf p

_find_poly = (x, y) ->
  _.find _polys, (p) ->
    [b1, b2, b3] = _.map [[0,1], [1,2], [2,0]], (bc) ->
      [b, c] = [_points[p[bc[0]]], _points[p[bc[1]]]]
      (x-_w*c.x)*(_h*b.y-_h*c.y) - (_w*b.x-_w*c.x)*(y-_h*c.y) < 0
    (b1 is b2) and (b2 is b3)

_on_down_edit = (e) ->
  [x, y] = [(_get_x e), (_get_y e)]
  (v=_find_closest_vertex x, y).hl = on
_on_up_edit = (e) -> p.hl = off for p in _points
_on_move_edit = (e) ->
  [x, y] = [(_get_x e), (_get_y e)]
  v = _.find _points, (p) -> p.hl is on
  [v.x, v.y] = [x/_w, y/_h] if v
_find_closest_vertex = (x, y) ->
  _.first _.sortBy _points, (p) -> _distance x, y, _w*p.x, _h*p.y

_resize = ->
  [_w, _h] = [window.innerWidth, window.innerHeight]
  [_canvas.width, _canvas.height] = [_w, _h]
  ___ "resized canvas to #{_w}x#{_h}"

_distance = (x0, y0, x1, y1) -> Math.sqrt (Math.pow x1-x0, 2)+(Math.pow y1-y0, 2)
_events =
  down: ['mousedown', 'touchstart']
  up: ['mouseup', 'touchend']
  move: ['mousemove', 'touchmove']
_get_x = (e, i=0) -> e.targetTouches?[i].pageX or e.clientX
_get_y = (e, i=0) -> e.targetTouches?[i].pageY or e.clientY
_add_event_listener = (el, event_key, fun) ->
  el.addEventListener event, ((e) ->
    fun e
    e.preventDefault()), no for event in _events[event_key]
