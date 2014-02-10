Snakes
==========

Built as a learning experiment.  Multiplayer "Snake" game using Ruby, WebSockets, and HTML canvas.  The game is accessible at [snakes.io](http://snakes.io).

## Application architecture

The application is divided into two parts, a (1) game server, and a (2) web server.  

Data (user names, scores, images, etc) is persisted through MongoDB, with a single user model shared between both the game server and the web server.


## Game Server
Snakes.io game server is powered by [Reel](https://github.com/celluloid/reel), a "fast, non-blocking evented web server" built atop [Celluloid](https://github.com/celluloid/celluloid), a concurrent object framework.  Celluloid is probably most well-known for powering [Sidekiq](https://github.com/mperham/sidekiq), an amazing background job processor for Ruby.

## Web Server
A simple Rails 4 application responsible for serving the website, authentication with Facebook, and asset compilation & management.
