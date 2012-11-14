// Generated by CoffeeScript 1.4.0
var color, i, io, polys, send, socks, update, _, ___;

___ = function(x) {
  return console.log(x);
};

_ = require('underscore');

color = (require('onecolor'))('hsv(0,100%,100%)');

polys = (function() {
  var _i, _results;
  _results = [];
  for (i = _i = 0; _i <= 9; i = ++_i) {
    _results.push(color);
  }
  return _results;
})();

socks = [];

io = (require('socket.io')).listen(4567);

io.sockets.on('connection', function(s) {
  socks.push(s);
  s.on('e', function(d) {
    ___("<<" + d);
    return update(d);
  });
  return s.on('fade_out', function(d) {
    var ss, _i, _len, _results;
    ___("<<" + d[0] + " " + d[1] + " fade out");
    _results = [];
    for (_i = 0, _len = socks.length; _i < _len; _i++) {
      ss = socks[_i];
      _results.push(ss.emit('fade_out', d));
    }
    return _results;
  });
});

update = function(i) {
  polys[i] = polys[i].hue(0.1, true);
  return send();
};

send = function() {
  var l, s, _i, _len, _results;
  l = _.map(polys, function(p) {
    return p.hex();
  });
  ___(">>" + s);
  _results = [];
  for (_i = 0, _len = socks.length; _i < _len; _i++) {
    s = socks[_i];
    _results.push(s.emit('u', l));
  }
  return _results;
};