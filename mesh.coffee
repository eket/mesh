___ = (x) -> console.log x
_ = require 'underscore'
color = (require 'onecolor') 'hsv(0,100%,100%)'
polys = (color for i in [0..9])
socks = []

io = (require 'socket.io').listen 4567
io.sockets.on 'connection', (s) ->
  socks.push s
  s.on 'e', (d) ->
    ___ "<<#{d}"
    update d

update = (i) ->
  polys[i] = polys[i].hue 0.01, yes
  send()

send = ->
  l = _.map polys, (p) -> p.hex()
  ___ ">>#{s}"
  s.emit 'u', l for s in socks
