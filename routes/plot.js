// Generated by CoffeeScript 1.6.2
(function() {
  var Snippet;

  Snippet = require('../core/snippet');

  module.exports = function(app) {
    return app.get('/plot', function(req, res) {
      if (!req.user) {
        req.flash('warning', 'must be logged in to view plots');
        return res.redirect('/404');
      }
      return res.render('plot', {
        user: req.user
      });
    });
  };

}).call(this);
