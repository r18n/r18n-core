# frozen_string_literal: true

require 'bigdecimal'

describe R18n::Locale do
  before :all do
    @ru = R18n.locale('ru')
    @en = R18n.locale('en')
  end

  it 'checks is locale exists' do
    expect(R18n::Locale.exists?('ru')).to be true
    expect(R18n::Locale.exists?('nolocale')).to be false
  end

  it 'sets locale properties' do
    locale_class = Class.new(R18n::Locale) do
      def self.name
        'Foo'
      end

      set one: 1
      set two: 2
    end
    locale = locale_class.new
    expect(locale.one).to eq(1)
    expect(locale.two).to eq(2)
  end

  it 'loads locale' do
    expect(@ru.class).to eq(R18n::Locales::Ru)
    expect(@ru.code).to  eq('ru')
    expect(@ru.title).to eq('Русский')
  end

  it 'loads locale by Symbol' do
    expect(R18n.locale(:ru)).to eq(R18n.locale('ru'))
  end

  it 'equals to another locale with same code' do
    expect(@en).not_to eq(@ru)
    expect(@en).to eq(R18n.locale('en'))
  end

  it 'prints human readable representation' do
    expect(@ru.inspect).to eq('Locale ru (Русский)')
  end

  it 'returns pluralization type by elements count' do
    expect(@en.pluralize(0)).to eq(0)
    expect(@en.pluralize(1)).to eq(1)
    expect(@en.pluralize(5)).to eq('n')
  end

  it "uses UnsupportedLocale if locale file isn't exists" do
    expect(@en).to be_supported

    unsupported = R18n.locale('nolocale-DL')
    expect(unsupported).not_to be_supported
    expect(unsupported).to be_kind_of(R18n::UnsupportedLocale)

    expect(unsupported.code).to eq('nolocale-dl')
    expect(unsupported.title.downcase).to eq('nolocale-dl')
    expect(unsupported.ltr?).to be true

    expect(unsupported.pluralize(5)).to eq('n')
    expect(unsupported.inspect.downcase).to eq('unsupported locale nolocale-dl')
  end

  it 'formats number in local traditions' do
    expect(@en.localize(-123_456_789)).to eq('−123,456,789')
  end

  it 'formats float in local traditions' do
    expect(@en.localize(-12_345.67)).to eq('−12,345.67')
    expect(@en.localize(BigDecimal('-12345.67'))).to eq('−12,345.67')
  end

  it 'translates month, week days and am/pm names in strftime' do
    R18n::I18n.new('ru')
    time = Time.at(0).utc

    expect(@ru.localize(time, '%a %A')).to eq('Чтв Четверг')
    expect(@ru.localize(time, '%b %B')).to eq('янв января')
    expect(@ru.localize(time, '%H:%M%p')).to eq('00:00 утра')
  end

  it 'generates locale code by locale class name' do
    expect(R18n.locale('ru').code).to    eq('ru')
    expect(R18n.locale('zh-CN').code).to eq('zh-CN')
  end

  it 'localizes date for human' do
    i18n = R18n::I18n.new('en')

    expect(@en.localize(Date.today + 2, :human, i18n: i18n)).to eq('after 2 days')
    expect(@en.localize(Date.today + 1, :human, i18n: i18n)).to eq('tomorrow')
    expect(@en.localize(Date.today,     :human, i18n: i18n)).to eq('today')
    expect(@en.localize(Date.today - 1, :human, i18n: i18n)).to eq('yesterday')
    expect(@en.localize(Date.today - 3, :human, i18n: i18n)).to eq('3 days ago')

    y2k = Date.parse('2000-05-08')
    expect(@en.localize(y2k, :human, now: y2k + 8, i18n: i18n)).to   eq('8th of May')
    expect(@en.localize(y2k, :human, now: y2k - 365, i18n: i18n)).to eq('8th of May, 2000')
  end

  it 'localizes times for human' do
    minute = 60
    hour   = 60 * minute
    day    = 24 * hour
    zero   = Time.at(0).utc
    now    = Time.now
    format = :human
    i18n_kwarg = { i18n: R18n::I18n.new('en') }

    expect(@en.localize(now + (70 * minute), format, **i18n_kwarg)).to eq('after 1 hour')
    expect(@en.localize(now + hour + minute, format, **i18n_kwarg)).to eq('after 1 hour')
    expect(@en.localize(now + (38 * minute), format, **i18n_kwarg))
      .to eq('after 38 minutes')
    expect(@en.localize(now + 5,             format, **i18n_kwarg)).to eq('now')
    expect(@en.localize(now - 15,            format, **i18n_kwarg)).to eq('now')
    expect(@en.localize(now - minute,        format, **i18n_kwarg)).to eq('1 minute ago')
    expect(@en.localize(now - hour + 59,     format, **i18n_kwarg))
      .to eq('59 minutes ago')
    expect(@en.localize(now - (2 * hour),    format, **i18n_kwarg)).to eq('2 hours ago')

    expect(@en.localize(zero + (7 * day),   format, **i18n_kwarg, now: zero))
      .to eq('8th of January 00:00')
    expect(@en.localize(zero + (50 * hour), format, **i18n_kwarg, now: zero))
      .to eq('after 2 days 02:00')
    expect(@en.localize(zero + (25 * hour), format, **i18n_kwarg, now: zero))
      .to eq('tomorrow 01:00')
    expect(@en.localize(zero - (13 * hour), format, **i18n_kwarg, now: zero))
      .to eq('yesterday 11:00')
    expect(@en.localize(zero - (50 * hour), format, **i18n_kwarg, now: zero))
      .to eq('3 days ago 22:00')

    expect(@en.localize(zero - (9   * day), format, **i18n_kwarg, now: zero))
      .to eq('23rd of December, 1969 00:00')
    expect(@en.localize(zero - (365 * day), format, **i18n_kwarg, now: zero))
      .to eq('1st of January, 1969 00:00')
  end

  it 'localizes date-times for human' do
    day    = 1.0
    hour   = day / 24
    minute = hour / 60
    second = minute / 60
    zero   = DateTime.new(1970)
    now    = DateTime.now
    format = :human
    i18n_kwarg = { i18n: R18n::I18n.new('en') }

    expect(@en.localize(now + (70 * minute), format, **i18n_kwarg)).to eq('after 1 hour')
    expect(@en.localize(now + hour + minute, format, **i18n_kwarg)).to eq('after 1 hour')
    expect(@en.localize(now + (38 * minute), format, **i18n_kwarg))
      .to eq('after 38 minutes')
    expect(@en.localize(now + (5 * second),  format, **i18n_kwarg)).to eq('now')
    expect(@en.localize(now - (15 * second), format, **i18n_kwarg)).to eq('now')
    expect(@en.localize(now - minute, format, **i18n_kwarg)).to eq('1 minute ago')

    expect(@en.localize(now - hour + (59 * second), format, **i18n_kwarg))
      .to eq('59 minutes ago')

    expect(@en.localize(now - (2 * hour), format, **i18n_kwarg)).to eq('2 hours ago')

    expect(@en.localize(zero + (7  * day),  format, **i18n_kwarg, now: zero))
      .to eq('8th of January 00:00')
    expect(@en.localize(zero + (50 * hour), format, **i18n_kwarg, now: zero))
      .to eq('after 2 days 02:00')
    expect(@en.localize(zero + (25 * hour), format, **i18n_kwarg, now: zero))
      .to eq('tomorrow 01:00')
    expect(@en.localize(zero - (13 * hour), format, **i18n_kwarg, now: zero))
      .to eq('yesterday 11:00')
    expect(@en.localize(zero - (50 * hour), format, **i18n_kwarg, now: zero))
      .to eq('3 days ago 22:00')

    expect(@en.localize(zero - (9  * day),  format, **i18n_kwarg, now: zero))
      .to eq('23rd of December, 1969 00:00')
    expect(@en.localize(zero - (365 * day), format, **i18n_kwarg, now: zero))
      .to eq('1st of January, 1969 00:00')
  end

  it 'uses standard formatter by default' do
    expect(@ru.localize(Time.at(0).utc)).to eq('01.01.1970 00:00')
  end

  it "doesn't localize time without i18n object" do
    expect(@ru.localize(Time.at(0))).not_to eq(Time.at(0).to_s)
    expect(@ru.localize(Time.at(0), :full)).not_to eq(Time.at(0).to_s)

    expect(@ru.localize(Time.at(0), :human)).to eq(Time.at(0).to_s)
  end

  it 'localizes date in custom formatter if exists' do
    allow(@en).to receive(:format_date_my_own_way) do |date|
      date == Date.today ? 'DOOMSDAY!' : 'Just another day'
    end

    expect(@en.localize(Date.today, :my_own_way)).to eq('DOOMSDAY!')
    expect(@en.localize(Date.today + 1, :my_own_way)).to eq('Just another day')
    expect(@en.localize(Date.today - 1, :my_own_way)).to eq('Just another day')
  end

  it 'localizes custom classes if formatter exists' do
    stub_const(
      'SomeProject::FooBar', Class.new do
        attr_reader :value

        def initialize(value)
          @value = value
        end
      end
    )

    foo_bar = SomeProject::FooBar.new 'something'

    ## I was fixing RuboCop offenses and have faced the issue: https://github.com/r18n/r18n/pull/239/checks?check_run_id=1542486592
    ##
    ## ```
    ## Failures:
    ##
    ##   1) R18n::Locale localizes custom classes if formatter exists
    ##      Failure/Error: send format_method_name, obj, *args, **kwargs
    ##
    ##      ArgumentError:
    ##        wrong number of arguments (given 1, expected 0)
    ##      # ./lib/r18n-core/locale.rb:205:in `localize'
    ##      # ./spec/locale_spec.rb:224:in `block (2 levels) in <top (required)>'
    ## ```
    ##
    ## I've done a little investigation and found that these codes have different behavior:
    ##
    ## ```ruby
    ## expect(@en).to receive(:format_some_project_foo_bar_human, &:value)
    ## expect(@en).to receive(:format_some_project_foo_bar_human) { |obj| obj.value }
    ## ```
    ##
    ## The first one (without `SymbolProc` offense) passing all arguments to the `value` method,
    ## which is simple reader (and expects no arguments).
    ##
    ## And the problem is when we try to make:
    ## ```ruby
    ## send :format_some_project_foo_bar_human, object, *args, **kwargs
    ## ```
    ## `value` receives (empty) `kwargs` as regular `{}` argument.

    # rubocop:disable Style/SymbolProc
    expect(@en).to receive(:format_some_project_foo_bar_human) { |obj| obj.value }
    # rubocop:enable Style/SymbolProc

    expect(@en.localize(foo_bar, :human)).to eq('something')
  end

  it 'raises error on unknown formatter' do
    expect do
      @ru.localize(Time.at(0).utc, R18n::I18n.new('ru'), :unknown)
    end.to raise_error(ArgumentError, /formatter/)
  end

  it 'deletes slashed from locale for security reasons' do
    locale = R18n.locale('../spec/translations/general/en')
    expect(locale).to be_kind_of(R18n::UnsupportedLocale)
  end

  it 'ignores code case in locales' do
    upcase   = R18n.locale('RU')
    downcase = R18n.locale('ru')
    expect(upcase).to eq(downcase)
    expect(upcase.code).to   eq('ru')
    expect(downcase.code).to eq('ru')

    upcase   = R18n.locale('nolocale')
    downcase = R18n.locale('nolocale')
    expect(upcase).to eq(downcase)
    expect(upcase.code).to   eq('nolocale')
    expect(downcase.code).to eq('nolocale')
  end

  it 'loads locale with underscore' do
    expect(R18n.locale('nolocale_DL').code).to eq('nolocale-dl')
  end
end
