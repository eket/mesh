___ = (x) -> console.log x

_distance = (x0, y0, x1, y1) -> Math.sqrt (Math.pow x1-x0, 2)+(Math.pow y1-y0, 2)
_events =
  down: ['mousedown', 'touchstart']
  up: ['mouseup', 'touchend']
  move: ['mousemove', 'touchmove']
_get_x = (e, i=0) -> e.targetTouches?[i].pageX or e.clientX
_get_y = (e, i=0) -> e.targetTouches?[i].pageY or e.clientY
_add_event_listener = (el, event_key, fun) ->
  el.addEventListener event, fun, no for event in _events[event_key]
_rem_event_listener = (el, event_key, fun) ->
  el.removeEventListener event, fun, no for event in _events[event_key]

_canvas = null
_context = null
[_w, _h] = [0,0]
_resize = ->
  [_w, _h] = [window.innerWidth, window.innerHeight]
  [_canvas.width, _canvas.height] = [_w, _h]
  ___ "resized canvas to #{_w}x#{_h}"

_init = ->
  ___ 'initialize canvas'
  window.addEventListener 'resize', _resize, no
  _canvas = document.getElementById 'mesh_canvas'
  _context = _canvas.getContext '2d'
  _resize()

  #_add_event_listener _canvas, 'down', _on_down_hl
  #_add_event_listener _canvas, 'up', _on_up_edit
  _add_event_listener _canvas, 'move', _on_move_hl

  _loop _context

_find_poly = (x, y) ->
  p = _.find _polys, (p) ->
    [b1, b2, b3] = _.map [[0,1], [1,2], [2,0]], (bc) ->
      [b, c] = [_points[p[bc[0]]], _points[p[bc[1]]]]
      (x-_w*c.x)*(_h*b.y-_h*c.y) - (_w*b.x-_w*c.x)*(y-_h*c.y) < 0
    (b1 is b2) and (b2 is b3)

_on_move_hl = (e) ->
  [x, y] = [(_get_x e), (_get_y e)]
  if p = _find_poly x, y
    p[3] = p[3].hue .01, yes




_find_closest_vertex = (x, y) ->
  _.first _.sortBy _points, (p) -> _distance x, y, _w*p.x, _h*p.y
_on_down_edit = (e) ->
  [x, y] = [(_get_x e), (_get_y e)]
  (v=_find_closest_vertex x, y).hl = on
_on_up_edit = (e) -> p.hl = off for p in _points
_on_move_edit = (e) ->
  [x, y] = [(_get_x e), (_get_y e)]
  v = _.find _points, (p) -> p.hl is on
  [v.x, v.y] = [x/_w, y/_h] if v
_dump = -> JSON.stringify ({x:p.x, y:p.y} for p in _points)




_loop = (__) ->
  __.clearRect 0, 0, _w, _h
  #__.strokeStyle = (one.color '#00f').css()
  #__.lineWidth = 2
  for p, v of _polys
    __.fillStyle = v[3].css()
    __.beginPath()
    __.moveTo _w*_points[v[0]].x, _h*_points[v[0]].y
    __.lineTo _w*_points[v[1]].x, _h*_points[v[1]].y
    __.lineTo _w*_points[v[2]].x, _h*_points[v[2]].y
    __.lineTo _w*_points[v[0]].x, _h*_points[v[0]].y
    __.fill()
    #__.stroke()

  window.webkitRequestAnimationFrame -> _loop __

_polys =
  a: [0, 1, 2]
  b: [1, 2, 3]
  c: [2, 3, 4]
  d: [2, 4, 5]
  e: [4, 5, 6]
  f: [5, 6, 7]
  g: [5, 7, 8]
  h: [0, 7, 8]
  i: [0, 2, 8]
  j: [2, 5, 8]
v.push (one.color '#f00') for k,v of _polys

_points =
[{"x":0.35346097201767307,"y":0.030165912518853696},{"x":0.7128129602356407,"y":0.03619909502262444},{"x":0.6892488954344624,"y":0.2579185520361991},{"x":0.9558173784977909,"y":0.3861236802413273},{"x":0.7245949926362297,"y":0.7345399698340875},{"x":0.45508100147275404,"y":0.5641025641025641},{"x":0.3711340206185567,"y":0.7601809954751131},{"x":0.025036818851251842,"y":0.3650075414781297},{"x":0.3873343151693667,"y":0.28808446455505277}]