# frozen_string_literal: true

describe R18n::Locales::Sv do
  it 'formats Swedish date' do
    sv = R18n::I18n.new('sv')
    expect(sv.l(Date.parse('2009-05-01'), :full)).to eq('1 maj 2009')
    expect(sv.l(Date.parse('2009-05-01'), :full, year: false)).to eq('1 maj')
  end
end
