function parseComments(jsonString) {
  var container = $('#comments');
  
  try {
    var comments = JSON.parse(jsonString);
  }
  catch(error) {
    container.html('<div class="error">' + error + '</div>');
    return;
  }
  
  clearComments();
  
  document.body.scrollTop = 0;
  
  if (!comments.length) {
    container.append('<p class="noComments"><span>No Comments</span></p>');
    return;
  }
  
  for (var i = 0; i < comments.length; i++) {
    var comment = comments[i];
    
    var content = comment.content;
    content = content.replace(/&#012;/g, "\n");
    
    var postClass = comment.isPost ? 'post' : '';
    
    var element = $('<div class="commentContainer margin-' + comment.margin + ' ' + postClass + '">' +
                      '<div class="meta">' +
                        '<span class="username">' +
                          '<span class="text">' +
                            comment.user +
                          '</span>' +
                          '<span class="minimizer">-</span>' +
                        '</span>' +
                        '<span class="createdAt">' +
                          comment.created +
                        '</span>' +
                      '</div>' +
                      content +
                    '</div>');
    
    container.append(element);
    
    if (comment.poll) {
      var polls = comment.poll;
      var sortedPolls = polls.sort(byPoints);
      var highestPoints = sortedPolls[0].points;
      var allPoints = 0;
      
      for (var i = 0; i < polls.length; i++) {
        allPoints += parseInt(polls[i].points);
      }
      
      for (var i = 0; i < polls.length; i++) {
        var poll  = polls[i];
        var width = poll.points / allPoints * 100;
        var percent = width.toFixed(2);
        
        var pollElement = $('<div class="poll">' +
                              '<div class="barContainer">' +
                                '<div class="bar" style="width:' + width + '%"></div>' +
                              '</div>' +
                              '<div class="text">' +
                                '<span class="points">' + percent + '%</span>' +
                                '<span class="title">' + poll.title + '</span>' +
                              '</div>' +
                            '</div>');
        
        element.append(pollElement);
      }
    }
  }
  
  $('.minimizer').click(didClickMinimizer);
}

function clearComments() {
  $('#comments').html('');
}

function didClickMinimizer(event) {
  var button = $(event.target);
  var commentContainer = button.parents('.commentContainer');

  if (button.html() === '-') {
    commentContainer.find('.meta').addClass('hidden');
    commentContainer.find('.comment').hide();
    minimizeNextComments(commentContainer, null);

    button.html('+');
  }
  else if (button.html() === '+') {
    commentContainer.find('.meta').removeClass('hidden');
    commentContainer.find('.comment').show();
    maximizeNextComments(commentContainer, null);

    button.html('-');
  }
}

function minimizeNextComments(startComment, initialMargin) {
  var startMargin = +startComment.attr('class').split('-')[1];

  if (initialMargin == null)
    initialMargin = startMargin;

  var nextComment = startComment.next();

  if (!nextComment.length)
    return;

  var nextMargin = +nextComment.attr('class').split('-')[1];

  if (nextMargin > initialMargin) {
    nextComment.hide();
    minimizeNextComments(nextComment, initialMargin);
  }
}

function maximizeNextComments(startComment, initialMargin) {
  var startMargin = +startComment.attr('class').split('-')[1];

  if (initialMargin == null)
    initialMargin = startMargin;

  var nextComment = startComment.next();

  if (!nextComment.length)
    return;

  var nextMargin  = +nextComment.attr('class').split('-')[1];

  if (nextMargin > initialMargin) {
    nextComment.show();
    maximizeNextComments(nextComment, initialMargin);
  }
}

function byPoints(a, b) {
  var a = +a.points;
  var b = +b.points;
  
  if (a > b)
    return -1;
  if (a < b)
    return 1;
  
  return 0;
}