(function() {
    var SocketKlass = "MozWebSocket" in window ? MozWebSocket : WebSocket;

    if (SocketKlass) {
      $(document).ready(function() {
        var animate, canvas, connect, context, id, sendDirection, server;
        server = null;
        canvas = $("#stage");

        if (!canvas) {
          return;
        }

        context = canvas.get(0).getContext("2d");
        id = $('meta[name=user_id]').attr("content");
        sendDirection = function(direction) {
          if (server) {
            return server.send(JSON.stringify({
              'type': 'direction',
              'value': direction
            }));
          }
        };
        animate = function(objects) {
          var element, snake, x, y, _i, _len, _results;
          context.fillStyle = 'rgb(255,255,255)';
          for (x = 0; x <= 49; x++) {
            for (y = 0; y <= 49; y++) {
              context.fillRect(x * 10, y * 10, 9, 9);
            }
          }
          _results = [];
          for (_i = 0, _len = objects.length; _i < _len; _i++) {
            obj = objects[_i];

            if (obj.type == "snake") {
              context.fillStyle = obj.id === id ? 'rgb(170,0,0)' : 'rgb(0,0,0)';
            } else if (obj.type == "food") { 
              context.fillStyle = 'rgb(0,170,0)';
            }
            
            if (obj.id === id) {
              // $("#kills").html("Kills: " + obj.kills);
              // $("#deaths").html("Deaths: " + obj.deaths);
            }

            _results.push((function() {
              var _j, _len2, _ref, _results2;
              _ref = obj.elements;
              _results2 = [];
              for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
                element = _ref[_j];
                x = element[0] * 10;
                y = element[1] * 10;
                _results2.push(context.fillRect(x, y, 9, 9));
              }
              return _results2;
            })());
          }
          return _results;
        };
        connect = function() {
          $('#btn-input').keypress(function (e) {
            if (e.which == 13) {
              $('#btn-chat').click();
            }
          });

          $('#btn-chat').click(function() {
            var input = $('#btn-input');
            var text = input.val().trim();
            input.val('');

            if (text.length > 0) {
              server.send(JSON.stringify({
                'type': 'chat_message',
                'value': text
              }));
            }
          })

          server = new SocketKlass('ws://' + $('meta[name=game_server_host]').attr("content") + '/socket'); 

          server.onopen = function() {
            server.send(JSON.stringify({
              'type': 'identify',
              'value': $('meta[name=user_id_hash]').attr("content")
            }));
          };

          return server.onmessage = function(event){
            message = JSON.parse(event.data);
            switch (message.type) {
              case 'chat_message':
                var chat_template = '<li class="{{if self}}left{{else}}right{{/if}} clearfix"><span class="chat-img pull-{{if self}}left{{else}}right{{/if}}"><img src="${image_url}" alt="User Avatar" class="img-circle" /></span><div class="chat-body clearfix"><div class="header"><strong class="{{if !self}}pull-right {{/if}}primary-font">${name}</strong></div><p>${message}</p></div></li>';
                $.tmpl( chat_template, { self: !(id == message.id), image_url: message.image_url, name: message.name, message: message.message }).appendTo( "#chat_box" );
                var n = $('#chat_box').height();
                $('.panel-body').animate({ scrollTop: n }, 50);
                break;
              case 'participants':
                var scoreboard = $('#scoreboard');
                for (_i = 0, _len = message.value.length; _i < _len; _i++) {
                  var div = $('<div>');
                  var user = message.value[_i];
                  var avatar = $('<img>').attr('src', user.image_url);
                  var name = user.first_name + ('('+user.wins + ' wins / ' + user.losses + ' losses)');
                  div.append(avatar);
                  div.append(name);
                  scoreboard.append(div);
                }
                break;
              case 'map':
                animate(message.value);
                break;
              case 'winner':
                alert(message.value);
                break;
            }
          }
        };
        connect();

        return $(document).keydown(function(event) {
          var key;
          key = event.keyCode ? event.keyCode : event.which;
          switch (key) {
            case 37:
              return sendDirection("left");
            case 38:
              return sendDirection("up");
            case 39:
              return sendDirection("right");
            case 40:
              return sendDirection("down");
          }
        });
      });

    } else {
      alert("Your browser does not support websockets.");
    }
  }).call(this);