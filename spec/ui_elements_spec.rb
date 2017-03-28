require_relative "../ui_elements"

RSpec.describe UIElements::FBCarousel do
  let(:carousel) { UIElements::FBCarousel.new }

  it 'parses an array of buttons into buttons hash' do
    expect(carousel.parse_buttons([])).to eq({})
  end
end
