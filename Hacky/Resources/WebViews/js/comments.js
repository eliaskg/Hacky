$(document).ready(function() {
  observeScroll();
});

function parseComments(jsonString) {
  var comments  = JSON.parse(jsonString);
  var container = $('#comments');
  container.html('');
  
  document.body.scrollTop = 0;
  
  for (var i = 0; i < comments.length; i++) {
    var comment = comments[i];
    var element = $('<div class="commentContainer margin-' + comment.margin + '">' +
                      '<div class="meta">' +
                        '<span class="username">' +
                          comment.user +
                        '</span>' +
                        '<span class="createdAt">' +
                          comment.created +
                        '</span>' +
                      '</div>' +
                      comment.content +
                    '</div>');
    
    container.append(element);
  }
}

function observeScroll() {
  $(document).on('scroll', function(event) {
    console.log(document.body.scrollTop); // you *really* don't want to alert in a scroll
  });
}