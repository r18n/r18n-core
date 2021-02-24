# R18n Core

[![Cirrus CI - Base Branch Build Status](https://img.shields.io/cirrus/github/r18n/r18n-core?style=flat-square)](https://cirrus-ci.com/github/r18n/r18n-core)
[![Codecov branch](https://img.shields.io/codecov/c/github/r18n/r18n-core/master.svg?style=flat-square)](https://codecov.io/gh/r18n/r18n-core)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/r18n/r18n-core.svg?style=flat-square)](https://codeclimate.com/github/r18n/r18n-core)
[![Depfu](https://img.shields.io/depfu/r18n/r18n-core?style=flat-square)](https://depfu.com/repos/github/r18n/r18n-core)
[![Inline docs](https://inch-ci.org/github/r18n/r18n-core.svg?branch=master)](https://inch-ci.org/github/r18n/r18n-core)
[![License](https://img.shields.io/github/license/r18n/r18n-core.svg?style=flat-square)](LICENSE)
[![Gem](https://img.shields.io/gem/v/r18n-core.svg?style=flat-square)](https://rubygems.org/gems/r18n-core)

[R18n](https://github.com/r18n/r18n) is an i18n tool to translate your Ruby application
into several languages.

You can use [wrapper plugins](https://github.com/r18n/r18n#wrapper-plugins)
like `r18n-rails` or `sinatra-r18n` to localize web applications
and `r18n-desktop` to localize desktop application.

## Features

* Nice Ruby-style syntax.
* Filters.
* Model Translation (or any Ruby object).
* Auto-detect user locales.
* Flexible locales.
* Total flexibility.

See full features in [main README](https://github.com/r18n/r18n/blob/master/README.md).

## Usage

To add i18n support to your app, we suggest you to use
[the particular plugin](https://github.com/r18n/r18n#wrapper-plugins) for your environment,
for example `r18n-rails`, `sinatra-r18n` or `r18n-desktop`.

If you develop you own plugin or want to use only core gem, you will need to
set default translation places and current locale:

```ruby
R18n.default_places = 'path/to/translations'
R18n.set('en')
```

You can use `R18n.t` to get translations and `R18n.l` to localize times and
numbers. But more useful is to add helpers to fast access the R18n:

```ruby
include R18n::Helpers

t.yes              #=> "Yes"
l Time.now, :human #=> "now"

r18n.locale.code   #=> "en"
```

To set locale only for current thread use `R18n.thread_set`.

### Translation

Translation files are in YAML format by default and have names like
`en.yml` (English) or `en-us.yml` (USA English dialect) with
language/country code (RFC 3066). Upcased region (`en-US`) and
`.yaml` file extension are also allowed.

In your translation files you can use:

*   Strings

    ```yaml
    robot: This is a robot
    percent: "Percent sign (%)"
    ```

*   Numbers

    ```yaml
    number: 123
    float: 12.45
    ```

*   Pluralizable messages

    ```yaml
    robots: !!pl
      0: No robots
      1: One robot
      n: '%1 robots'
    ```

*   Filters

    ```yaml
    filtered: !!custom_type
      This content will be processed by a filter
    ```

To get the translated string use a method with the key name or square brackets
[] for keys, which is the same with Object methods (`class`, `inspect`, etc):

```ruby
t.robot    #=> "This is a robot"
t[:robot]  #=> "This is a robot"
```

Translation may be hierarchical:

```ruby
t.post.add     #=> "Add post"
t[:post][:add] #=> "Add post"
```

If the locale isn't found in the user's requested locale, R18n will search for
it in sublocales or in another locale, which the user also can accept:

```ruby
t.not.in.english #=> "В английском нет"
```

The translated string has a `locale` method for determining its locale (Locale
instance or code string if locale is't supported in R18n):

```ruby
i18n.not.in.english.locale #=> Locale ru (Русский)
```

You can include parameters in the translated string by specifying arguments:

```yaml
name: My name is %1
```

```ruby
t.name('John') #=> "My name is John"
```

Pluralizable messages get their item count from the first argument:

```ruby
t.robots(0)  #=> "No robots"
t.robots(1)  #=> "One robot"
t.robots(50) #=> "50 robots"
```

If there isn't a pluralization for a particular number, translation will be use
`n`. If there isn't a locale file for translation, it will use the English
pluralization rule (`0`, `1` and `n`).

You can check if the key has a translation:

```ruby
t.post.add.translated?   #=> true
t.not.exists.translated? #=> false
```

You can set a default value for untranslated strings:

```ruby
t.not.exists | 'default' #=> "default"
```

You can query the translation keys:

```ruby
t.counties.translation_keys.each do |county|
  puts t.counties[county]
end
```

R18n already has translations for common words for most built in locales.
See `base/` the source.

```ruby
t.yes    #=> "Yes"
t.cancel #=> "Cancel"
t.delete #=> "Delete"
```

### Filters

You can also add you own filters for translations: escape HTML entities, convert
from Markdown syntax, etc. Filters can be passive, only being processed when
loaded.

```yaml
friendship: !!gender
  f: She adds a friend
  m: He adds a friend
```

```ruby
R18n::Filters.add('gender', :user_gender) do |content, config, user|
  if user.female?
    content['f']
  else
    content['m']
  end
end

t.friendship(anne) #=> "She adds a friend"
```

To create a filter you pass the following to `R18n::Filters.add`:

* Filter target. YAML type (`!!type`), `String` for all translations of
  `R18n::Untranslated` for missing translations.
* Optional filter name, to disable, enable or delete it later by
  `R18n::Filters.off`, `R18n::Filters.on` and
  `R18n::Filters.delete`.
* `Hash` with options:
  * `passive: true` to filter translations only on load;
  * `:position` within the list of current filters of this type
    (by default a new filter will be inserted into last position).

The filter will receive at least two arguments:
* Translation (possibly already filtered by other filters for this type earlier
  in the list).
* A `Hash` with translation `locale` and `path`.
* Parameters from translation request will be in the remaining arguments.

In Rails application put your filters to `app/i18n/filters.rb`, it will be
automatically reloaded in development.

#### HTML Escape

R18n contains 2 filters to escape HTML entities: by YAML type and global. If you
need to escape HTML in some translations, just set `!!escape` YAML type:

```yaml
greater: !!escape
  1 < 2 is true
```

```ruby
t.greater #=> "1 &lt; 2 is true"
```

If you develop web application and want to escape HTML in all translations, just
activate the global escape filter:

```ruby
R18n::Filters.on(:global_escape_html)
```

If you enable global HTML escape, you may still use `!!html` YAML type to
disable escaping on some values:

```yaml
warning: !!html
  <b>Warning</b>
```

```ruby
R18n::Filters.on(:global_escape_html)
t.warning #=> "<b>Warning</b>"
```

#### Markdown

To use Markdown in your translations you must install the Kramdown gem:

```yaml
hi: !!markdown
  **Hi**, people!
```

```ruby
t.hi #=> "<p><strong>Hi</strong>, people!</p>"
```

If you can't use Kramdown you can redefine Markdown filter
to use your own parser:

```ruby
# Disable standard Markdown filter
Filters.off(:kramdown)
# Add new filter for !!markdown YAML type
Filters.add('markdown', passive: true) do |content, config|
  require 'redcarpet'
  markdown = ::Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(content)
end
```

#### Textile

To use Textile in your translations you must install the `RedCloth` gem:

```yaml
alarm: !!textile
  It will delete _all_ users!
```

```ruby
t.alarm #=> "<p>It will delete <em>all</em> users!</p>"
```

#### Named variables

After enabling built-in `named_variables` filter, you can use named variables
in all translations:

```yaml
greeting: "Hi, %{name}"
users: !!pl
  1: One user
  n: {{count}} users
```

```ruby
Filters.on(:named_variables)

t.greeting(name: 'John') #=> "Hi, John"
t.users(count: 5)        #=> "5 users"
```

### Localization

You can print numbers and floats according to the rules of the user locale:

```ruby
l -12000.5 #=> "−12,000.5"
```

Number and float formatters will also put real typographic minus and put
non-breakable thin spaces (for locale, which use it as digit separator).

You can translate months and week day names in `Time`, `Date` and `DateTime`
by the `strftime` method:

```ruby
l Time.now, '%B'  #=> "September"
```

R18n has some built-in time formats for locales: `:human`, `:full` and
`:standard` (the default):

```ruby
l Time.now, :human #=> "now"
l Time.now, :full  #=> "August 9th, 2009 21:47"
l Time.now         #=> "2009-08-09 21:41"
l Time.now.to_date #=> "2009-08-09"
```

### Model

You can add i18n support to any classes, including ORM models (`ActiveRecord`,
`Sequel`, `DataMapper`, `MongoMapper`, `Mongoid` or others):

```ruby
class Product
  include DataMapper::Resource
  property :title_ru, String
  property :title_en, String

  include R18n::Translated
  translations :title
end

# For example, user only knows Russian

# Set English (default) title
product.title_en = "Anthrax"
product.title #=> "Anthrax"

# Set value for user locale (Russian)
product.title = "Сибирская язва"
product.title #=> "Сибирская язва"

product.title_en #=> "Anthrax"
product.title_ru #=> "Сибирская язва"
```

See `R18n::Translated` for documentation.

### Locale

All supported locales are stored in `r18n-core` gem in `locales/` directory.
If you want to add your locale, please see the ["Add Locale"](#add-locale)
section.

To get information about a locale create an `R18n::Locale` instance:

```ruby
locale = R18n.locale('en')
```

You can then get the following from the locale:

*   Locale title and RFC 3066 code:

    ```ruby
    locale.title #=> "English"
    locale.code  #=> "en"
    ```

*   Language direction (left to right, or right to left for Arabic and Hebrew):

    ```ruby
    locale.ltr? #=> true
    ```

*   Week start day (`:monday` or `:sunday`):

    ```ruby
    locale.week_start #=> :sunday
    ```

### Loaders

You can load translations from anywhere, not just from YAML files. To load
translation you must create loader class with 2 methods:

* `available` – return array of locales of available translations;
* `load(locale)` – return `Hash` of translation.

Pass its instance to `R18n.default_places` or `R18n.set(locales, loaders)`

```ruby
R18n.default_places = MyLoader.new(loader_param)
R18n.set('en')
```

You can set your default loader and pass it to `R18n.set` as the only
constructor argument:

```ruby
R18n.default_loader = MyLoader
R18n.default_places = loader_param

R18n.set('en')
R18n.set('en', different_loader_param)
```

If you want to load a translation with some type for filter, use
`R18n::Typed` struct:

```ruby
# Loader will return something like:
{ 'users' => R18n::Typed.new('pl', { 1 => '1 user', 'n' => '%1 users' }) }

# To use pluralization filter ("pl" type):
t.users(5) #=> "5 users"
```

You can also set several loaders to merge translations from different sources:

```ruby
R18n.default_places = [MyLoader.new, DBLoader.new, 'path/to/yaml']
```

### Extension Translations

For r18n plugin you can add loaders with translations, which will be used with
application translations. For example, DB plugin may place translations for
error messages in extension directory. R18n contain translations for base words
as extension directory too.

```ruby
R18n.extension_places << R18n::Loader::YAML.new('./error_messages/')
```

## Add Locale

If R18n has not got locale file for your language, please add it. It's very
simple:

* Create the file `%{code}.rb` for your language and describe locale, then
  require it in the project. Just copy from another locale and change the
  values.
  * If your country has alternate languages (for example, in exUSSR countries
    most people also know Russian), add
    `sublocales %w[%{another_locale} en]`.
* If your language needs some special logic (for example, different
  pluralization or time formatters) you can extend `R18n::Locale` class methods.

If you want to send a pull request:

* Move your `%{code}.rb` file in the `locales/` directory.
* Create `%{code}.yml` file for your language in the `base/` directory and
  translate the base messages. Just copy file from language, which you know,
  and rewrite values.
* Send a pull request via GitHub <http://github.com/r18n/r18n> or just write
  email with the files to [Andrey Sitnik](mailto:andrey@sitnik.ru)
  or [Alexander Popov](mailto:alex.wayfer@gmail.com).

`%{code}` is RFC 3066 code for your language (for example, `en` for English and
`fr-CA` for Canadian French). Email me with any questions you may have, you will
find other contact addresses at [sitnik.ru](https://sitnik.ru/).

## License

R18n is licensed under the GNU Lesser General Public License version 3.
See the LICENSE file or [www.gnu.org/licenses/lgpl-3.0.html](https://www.gnu.org/licenses/lgpl-3.0.html).

## Author

Andrey “A.I.” Sitnik [andrey@sitnik.ru](mailto:andrey@sitnik.ru)
