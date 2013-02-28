// From http://rohanradio.com/blog/2011/02/22/posting-json-with-jquery/

jQuery.extend({
  postJSON: function(url, data, callback) {
    return jQuery.ajax({
      type: "POST",
      url: url,
      data: JSON.stringify(data),
      success: callback,
      dataType: "json",
      contentType: "application/json",
      processData: false
    });
  }
});
