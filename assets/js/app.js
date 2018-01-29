// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import Clipboard from "clipboard"

// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

$('.clipboard').tooltip({
  trigger: 'click',
  placement: 'bottom'
});

function setTooltip(message) {
  $('.clipboard').tooltip('hide')
    .attr('data-original-title', message)
    .tooltip('show');
}

function hideTooltip() {
  setTimeout(function() {
    $('.clipboard').tooltip('hide');
  }, 1000);
}

// Clipboard

const clipboard = new Clipboard('.clipboard');

clipboard.on('success', function(e) {
  setTooltip('复制成功！');
  hideTooltip();
});

// Message
setTimeout(function() {
    $('.alert').fadeOut('fast');
}, 1500);
