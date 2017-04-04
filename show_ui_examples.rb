module ShowUIExamples
  def show_button_template
    UI::FBButtonTemplate.new(SampleElements::BUTTON_TEMPLATE_TEXT,
                             SampleElements::BUTTON_TEMPLATE_BUTTONS).send(@user.id)
                             # TODO: send to (@user) directly?
  end
end
