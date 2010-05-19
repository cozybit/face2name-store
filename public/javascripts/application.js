// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
//$(function(){ $("select").uniform(); });
//$("select, input:checkbox, input:radio, input:file").uniform();

$(document).ready(function() {
  var yellow_flash = function($flasher, start_color) {
    $flasher.css('background-color', '#FFFFC7');

    setTimeout(function() {
      console.log('animate');
      $flasher.animate({ backgroundColor: start_color }, 1000);
    }, 500);
  };

  $('.user_field_toggle').change(function() {
    var $checkbox = $(this);
    var $td = $($checkbox.parent('td'));
    var data = {
          _method: 'PUT'
    };
    data['[user]' + $checkbox.attr('name')] = $checkbox.is(':checked');

    $td.addClass('spinner');
    $.ajax({ type: 'POST', url: $checkbox.attr('rel'), data: data, dataType: 'json',
      success: function(data, textStatus, XMLHttpRequest) {
        $td.removeClass('spinner');
        yellow_flash($checkbox.parents('tr'), '#FFFFFF');
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
        $td.removeClass('spinner');
        yellow_flash($checkbox.parent('tr'));
      }
    });
  });
});