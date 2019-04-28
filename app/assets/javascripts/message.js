$(document).on(`turbolinks:load`, function () {
  var eventId = $(`#event_id`).val();
  var currentUserId = $(`#current_user_id`).val();

  $(`.message_detail`).each(function() {
    checkDeleteable(this);
  });

  App.message = App.cable.subscriptions.create({
    channel: `MessageChannel`,
    event_id: eventId}, {
    connected: function () { },
    received: function (data) {
      if (data.message !== undefined) {
        var message = data.message;
        var messUserIsCurrentUser = (currentUserId == message.user_id);

        if (data.method === `create` && !messUserIsCurrentUser) {
          $(`#messages`).append(message.html);
          checkDeleteable(`.message_detail:last`);
        } else if (data.method === `destroy` && !messUserIsCurrentUser) {
          $(`#message_${message.id}`).remove();
        }
      }
    }
  });
});

function checkDeleteable(element) {
  var senderId = $(`#messages`).data(`sender-id`);

  if ($(element).data(`message-user-id`) === senderId) {
    $(element).find(`.destroy_message`).css(`display`, `inherit`);
    $(element).find(`img.user_image_x_small, span.child`).css(`display`, `none`);
    $(element).find(`h5.display_space_between`).removeClass(`display_space_between`)
      .addClass(`display_flex_end`);
    $(element).find(`p`).addClass(`display_flex_end`);
  }
}
