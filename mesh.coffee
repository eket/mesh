# socket.io port
SIO = (parseInt process.argv[2]) or 4567

_ = require 'underscore'
color = (require 'onecolor') 'hsv(0,100%,100%)'

___ = (x) -> console.log x

socks = []
io = (require 'socket.io').listen SIO
io.sockets.on 'connection', (s) ->
  socks.push s
  s.on 'e', (d) ->
    ___ "<<#{d}"
    update d
  s.on 'fade_out', (d) ->
    ___ "<<#{d[0]} #{d[1]} fade out"
    ss.emit 'fade_out', d for ss in socks
___ "opened socket.io #{SIO}"
    
polys = (color for i in [0..9])
update = (i) ->
  polys[i] = polys[i].hue 0.1, yes
  send()

send = ->
  l = _.map polys, (p) -> p.hex()
  ___ ">>#{s}"
  s.emit 'u', l for s in socks
