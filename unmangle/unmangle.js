// Generated by IcedCoffeeScript 1.3.3d
(function() {

  exports.unmangle = function(mangled, query) {
    var buf, buf2, hit, k, matching, q, query2, spaces, v, vm, _i, _len;
    vm = require('vm');
    if (query.constructor === String) {
      query = query.replace(/^\?/, '').trim('&').split('&').map(function(tq) {
        return tq.split('=');
      });
      query2 = {};
      for (_i = 0, _len = query.length; _i < _len; _i++) {
        q = query[_i];
        if (q.length === 2) query2[q[0]] = decodeURIComponent(q[1]);
      }
      query = query2;
    }
    buf = [];
    while (matching = mangled.match(/([ ]*)#if ([^\r\n]+)\r?\n/)) {
      buf.push(mangled.substring(0, matching.index));
      mangled = mangled.substring(matching.index + matching[0].length);
      buf2 = [];
      buf2.push('(function(){');
      for (k in query) {
        v = query[k];
        buf2.push('var ');
        buf2.push(k);
        buf2.push('=');
        buf2.push(JSON.stringify(String(v)));
        buf2.push(';');
      }
      buf2.push('return ');
      buf2.push(matching[2]);
      buf2.push(';}).call(null)');
      hit = eval(buf2.join(''));
      buf2.splice(0);
      spaces = matching[1] + '  ';
      matching = mangled.match(/\r?\n/);
      buf2.push(mangled.substring(0, matching.index + matching[0].length));
      mangled = mangled.substring(matching.index + matching[0].length);
      while (mangled.substring(0, spaces.length) === spaces) {
        matching = mangled.match(/\r?\n/) || mangled.match(/.$/);
        buf2.push(mangled.substring(0, matching.index + matching[0].length));
        mangled = mangled.substring(matching.index + matching[0].length);
      }
      if (hit) mangled = buf2.join('') + mangled;
    }
    buf.push(mangled);
    return buf.join('');
  };

}).call(this);
