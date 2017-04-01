module ShowUIExamples
  # TODO: Follow (user, message) convention 
  def show_button_template(id)
    UI::FBButtonTemplate.new(SampleElements::BUTTON_TEMPLATE_TEXT,
                             SampleElements::BUTTON_TEMPLATE_BUTTONS).send(id)
  end
end
