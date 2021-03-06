module RequirementsHelper
  def rescue_req_deadline req
    req.deadline&.strftime Settings.model.event.date_format
  end

  def req_verified? verified
    return fa_icon "check", class: "pass" if verified
    fa_icon "times", class: "failed"
  end

  def verify_req verified
    return fa_icon "times", class: "failed" if verified
    fa_icon "check", class: "pass"
  end

  def requirement_collection event, conversation
    return UserEventRequirement.by(current_user, event) if current_user.Student?
    UserEventRequirement.by conversation.recipient(current_user), event
  end

  def rescue_images index, size
    return "d-none" if index != size - 1
  end

  def rescue_image_label requirement, form_builder
    requirement.images[form_builder.index]&.id || form_builder.hash
  end

  def rescue_requirement_status requirement
    return "unapprove" if requirement.verified?
    "approve"
  end
end
