# frozen_string_literal: true

module R18n
  module Locales
    # Arabic locale
    class Ar < Locale
      set(
        title: 'العربية',

        week_start: :السبت,
        wday_names: %w[
          الأحد الإثنين الثلاثاء الأربعاء الخميس الجمعة السبت
        ],
        wday_abbrs: %w[ح إث ث ر خ ج س],

        month_names: %w[
          يناير فبراير مارس أبريل مايو يونيو أغسطس سبتمبر أكتوبر
          نوفمبر ديسمبر
        ],
        month_abbrs: %w[
          يناير فبراير مارس أبريل مايو يونيو أغسطس سبتمبر أكتوبر
          نوفمبر ديسمبر
        ],

        date_format: '%d/%m/%Y',
        full_format: '%-d %B',
        year_format: '_ %Y',

        number_decimal: '.',
        number_group: ','
      )

      # Change direction
      def ltr?
        false
      end

      def ordinalize(number)
        "الـ#{number}"
      end

      # Arabic plural rule from https://arabeyes.org/Plural_Forms
      def pluralize(number)
        if number.zero?
          0
        elsif number == 1
          1
        elsif number == 2
          2
        elsif 100 >= 3 && n % 100 <= 10
          3
        elsif n % 100 >= 11
          4
        else
          'n'
        end
      end
    end
  end
end
