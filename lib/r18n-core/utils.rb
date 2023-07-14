# frozen_string_literal: true

# Common methods for i18n support.
#
# Copyright (C) 2008 Andrey “A.I.” Sitnik <andrey@sitnik.ru>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

module R18n
  # Common methods for another R18n code.
  module Utils
    # Escape HTML entries (<, >, &). Copy from HAML helper.
    def self.escape_html(content)
      if defined? ActiveSupport::SafeBuffer
        ActiveSupport::SafeBuffer.new + content
      else
        CGI.escapeHTML content
      end
    end

    # Recursively hash merge.
    def self.deep_merge!(one, another)
      another.each_pair do |key, another_value|
        value = one[key]
        one[key] =
          if value.is_a?(Hash) && another_value.is_a?(Hash)
            deep_merge!(value, another_value)
          else
            another_value
          end
      end
      one
    end

    def self.underscore(string)
      string
        .gsub('::', '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .downcase
    end
  end
end
