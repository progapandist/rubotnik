require_relative "../ui_elements"

# TODO: Private methods tests. Get rid of before publishing!
RSpec.describe UIElements::FBCarousel do
  let(:carousel) { UIElements::FBCarousel.new }

  it 'returns an empty array if buttons not present or empty' do
    expect(carousel.parse_buttons([])).to eq([])
    expect(carousel.parse_buttons(nil)).to eq([])
  end

  it 'raises ArgumentError if button type is not supported' do
    expect {carousel.parse_buttons([{type: :none}])}.to raise_error(/butt/)
  end

  it 'correctly parses an array of buttons' do
    buttons_in = [
      {type: :web_url, url: "http://google.com", title: "Google"},
      {type: :postback, title: "Do something", payload: "DO_IT"},
      {type: "postback", title: "Do something", payload: "DO_IT"},
    ]
    buttons_out = [
      {type: "web_url", url: "http://google.com", title: "Google"},
      {type: "postback", title: "Do something", payload: "DO_IT"},
      {type: "postback", title: "Do something", payload: "DO_IT"},
    ]
    expect(carousel.parse_buttons(buttons_in)).to eq(buttons_out)
  end
end
