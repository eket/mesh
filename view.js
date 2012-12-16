// Generated by CoffeeScript 1.4.0
var SIO, v, ___, _add_event_listener, _canvas, _context, _distance, _dump, _edit_mode_on, _events, _fade_out, _find_closest_vertex, _find_poly, _get_x, _get_y, _h, _i, _init, _len, _loop, _on_down_edit, _on_down_fade, _on_move_edit, _on_move_hl, _on_up_edit, _points, _polys, _ref, _resize, _send, _send_fade_out, _sock, _w;

SIO = ':4567';

_polys = [[0, 1, 2], [1, 2, 3], [2, 3, 4], [3, 4, 5], [4, 5, 6], [4, 6, 7], [6, 7, 8], [0, 7, 8], [0, 2, 7], [2, 4, 7]];

for (_i = 0, _len = _polys.length; _i < _len; _i++) {
  v = _polys[_i];
  v.push(one.color('#f00'));
}

_points = [
  {
    "x": 0.33984375,
    "y": 0.044921875
  }, {
    "x": 0.71328125,
    "y": 0.083984375
  }, {
    "x": 0.640625,
    "y": 0.171875
  }, {
    "x": 0.9328125,
    "y": 0.4892578125
  }, {
    "x": 0.5484375,
    "y": 0.6611328125
  }, {
    "x": 0.691800878477306,
    "y": 0.9283854166666666
  }, {
    "x": 0.2328125,
    "y": 0.8857421875
  }, {
    "x": 0.2421875,
    "y": 0.314453125
  }, {
    "x": 0.0921875,
    "y": 0.396484375
  }
];

___ = function(x) {
  return console.log(x);
};

_sock = null;

_canvas = null;

_context = null;

_ref = [0, 0], _w = _ref[0], _h = _ref[1];

_dump = function() {
  var p;
  return JSON.stringify((function() {
    var _j, _len1, _results;
    _results = [];
    for (_j = 0, _len1 = _points.length; _j < _len1; _j++) {
      p = _points[_j];
      _results.push({
        x: p.x,
        y: p.y
      });
    }
    return _results;
  })());
};

_send = function(i) {
  ___(">>" + i);
  return _sock.emit('e', i);
};

_send_fade_out = function(i, d) {
  ___(">>" + i + " fade out");
  return _sock.emit('fade_out', [i, d]);
};

_edit_mode_on = function() {
  _add_event_listener(_canvas, 'down', _on_down_edit);
  _add_event_listener(_canvas, 'up', _on_up_edit);
  return _add_event_listener(_canvas, 'move', _on_move_edit);
};

_init = function() {
  ___('initialize canvas');
  window.addEventListener('resize', _resize, false);
  _canvas = document.getElementById('mesh_canvas');
  _context = _canvas.getContext('2d');
  _resize();
  _add_event_listener(_canvas, 'move', _.throttle(_on_move_hl, 50));
  _add_event_listener(_canvas, 'down', _on_down_fade);
  ___('initialize socket');
  _sock = io.connect(SIO);
  _sock.on('connect', function() {
    ___('connected');
    _sock.on('u', function(d) {
      var i, p, _j, _len1, _results;
      _results = [];
      for (i = _j = 0, _len1 = d.length; _j < _len1; i = ++_j) {
        p = d[i];
        _results.push(_polys[i][3] = one.color(p));
      }
      return _results;
    });
    return _sock.on('fade_out', function(d) {
      return _fade_out(d[0], d[1]);
    });
  });
  return _loop(_context);
};

_fade_out = function(i, duration) {
  return _polys[i][4] = [
    Date.now(), duration, function(v, t) {
      if ((0 < t && t < 1)) {
        return v[3].lightness(v[3].lightness() * (0.5 + (t / 2.0)));
      } else {
        return v[3];
      }
    }
  ];
};

_loop = function(__) {
  var i, now, sh_duration, sh_fun, sh_start, _j, _len1, _ref1;
  __.clearRect(0, 0, _w, _h);
  now = Date.now();
  for (i = _j = 0, _len1 = _polys.length; _j < _len1; i = ++_j) {
    v = _polys[i];
    if (v[4] != null) {
      _ref1 = v[4], sh_start = _ref1[0], sh_duration = _ref1[1], sh_fun = _ref1[2];
    }
    __.fillStyle = (sh_fun != null ? sh_fun(v, (now - sh_start) / sh_duration) : v[3]).css();
    __.beginPath();
    __.moveTo(_w * _points[v[0]].x, _h * _points[v[0]].y);
    __.lineTo(_w * _points[v[1]].x, _h * _points[v[1]].y);
    __.lineTo(_w * _points[v[2]].x, _h * _points[v[2]].y);
    __.lineTo(_w * _points[v[0]].x, _h * _points[v[0]].y);
    __.fill();
  }
  return window.webkitRequestAnimationFrame(function() {
    return _loop(__);
  });
};

_on_down_fade = function(e) {
  var p, x, y, _ref1;
  _ref1 = [_get_x(e), _get_y(e)], x = _ref1[0], y = _ref1[1];
  if ((p = _find_poly(x, y)) != null) {
    return _send_fade_out(_polys.indexOf(p), 5000);
  }
};

_on_move_hl = function(e) {
  var p, x, y, _ref1;
  _ref1 = [_get_x(e), _get_y(e)], x = _ref1[0], y = _ref1[1];
  if (p = _find_poly(x, y)) {
    return _send(_polys.indexOf(p));
  }
};

_find_poly = function(x, y) {
  return _.find(_polys, function(p) {
    var b1, b2, b3, _ref1;
    _ref1 = _.map([[0, 1], [1, 2], [2, 0]], function(bc) {
      var b, c, _ref1;
      _ref1 = [_points[p[bc[0]]], _points[p[bc[1]]]], b = _ref1[0], c = _ref1[1];
      return (x - _w * c.x) * (_h * b.y - _h * c.y) - (_w * b.x - _w * c.x) * (y - _h * c.y) < 0;
    }), b1 = _ref1[0], b2 = _ref1[1], b3 = _ref1[2];
    return (b1 === b2) && (b2 === b3);
  });
};

_on_down_edit = function(e) {
  var x, y, _ref1;
  _ref1 = [_get_x(e), _get_y(e)], x = _ref1[0], y = _ref1[1];
  return (v = _find_closest_vertex(x, y)).hl = true;
};

_on_up_edit = function(e) {
  var p, _j, _len1, _results;
  _results = [];
  for (_j = 0, _len1 = _points.length; _j < _len1; _j++) {
    p = _points[_j];
    _results.push(p.hl = false);
  }
  return _results;
};

_on_move_edit = function(e) {
  var x, y, _ref1, _ref2;
  _ref1 = [_get_x(e), _get_y(e)], x = _ref1[0], y = _ref1[1];
  v = _.find(_points, function(p) {
    return p.hl === true;
  });
  if (v) {
    return _ref2 = [x / _w, y / _h], v.x = _ref2[0], v.y = _ref2[1], _ref2;
  }
};

_find_closest_vertex = function(x, y) {
  return _.first(_.sortBy(_points, function(p) {
    return _distance(x, y, _w * p.x, _h * p.y);
  }));
};

_resize = function() {
  var _ref1, _ref2;
  _ref1 = [window.innerWidth, window.innerHeight], _w = _ref1[0], _h = _ref1[1];
  _ref2 = [_w, _h], _canvas.width = _ref2[0], _canvas.height = _ref2[1];
  return ___("resized canvas to " + _w + "x" + _h);
};

_distance = function(x0, y0, x1, y1) {
  return Math.sqrt((Math.pow(x1 - x0, 2)) + (Math.pow(y1 - y0, 2)));
};

_events = {
  down: ['mousedown', 'touchstart'],
  up: ['mouseup', 'touchend'],
  move: ['mousemove', 'touchmove']
};

_get_x = function(e, i) {
  var _ref1;
  if (i == null) {
    i = 0;
  }
  return ((_ref1 = e.targetTouches) != null ? _ref1[i].pageX : void 0) || e.clientX;
};

_get_y = function(e, i) {
  var _ref1;
  if (i == null) {
    i = 0;
  }
  return ((_ref1 = e.targetTouches) != null ? _ref1[i].pageY : void 0) || e.clientY;
};

_add_event_listener = function(el, event_key, fun) {
  var event, _j, _len1, _ref1, _results;
  _ref1 = _events[event_key];
  _results = [];
  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
    event = _ref1[_j];
    _results.push(el.addEventListener(event, (function(e) {
      fun(e);
      return e.preventDefault();
    }), false));
  }
  return _results;
};