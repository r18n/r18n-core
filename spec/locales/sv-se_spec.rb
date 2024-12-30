# frozen_string_literal: true

describe R18n::Locales::SvSE do
  it 'formats Swedish (Sweden) date' do
    sv_se = R18n::I18n.new('sv-se')
    expect(sv_se.l(Date.parse('2009-05-01'), :full)).to eq('1 maj 2009')
    expect(sv_se.l(Date.parse('2009-05-01'), :full, year: false)).to eq('1 maj')
  end
end
