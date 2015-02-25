module Mroonga
  extend ActiveSupport::Concern

  included do
    scope :mrn_search, ->(query, columns, options = {}) do
      return if query.nil? or query == ''
      query = mrn_escape_query(query)

      pragma = "*" if options[:default_operator] or options[:weight]
      pragma << "W#{options[:weight]}" if options[:weight]
      pragma << "D#{options[:default_operator]}" if options[:default_operator]
      mode = options[:mode] || "IN BOOLEAN MODE"

      if options[:near].instance_of?(Array)
        near = "*N\"#{options[:near].join(" ")}\""
      elsif options[:near].instance_of?(Hash)
        if options[:near][:distance] and options[:near][:words]
          near = "*N#{options[:near][:distance]}\"#{options[:near][:words].join(" ")}\""
        end
      end
      if options[:similar].instance_of?(Array)
        similar = "*S\"#{options[:similar].join(" ")}\""
      elsif options[:similar].instance_of?(Hash)
        if options[:similar][:threshold] and options[:similar][:words]
          similar = "*S#{options[:similar][:threshold]}\"#{options[:similar][:threshold].join(" ")}\""
        end
      end

      query_string = "MATCH(#{columns}) AGAINST('#{pragma} #{query} #{near} #{similar}' #{mode})"

      where(query_string)
    end

    scope :mrn_snippet, ->(query, snippet_columns, options = {}) do
      return if query.nil? or query == ''
      keywords = mrn_extract_keywords(query)
      return if keywords.nil? or keywords == []

      keyword_prefix = options[:keyword_prefix] || "<span class=\"keyword\">"
      keyword_suffix = options[:keyword_suffix] || "</span>"
      max_bytes = options[:max_bytes] || 150
      max_count = options[:max_count] || 3
      encoding = options[:encoding] || "ascii_general_ci"
      skip_leading_spaces = options[:skip_leading_spaces] || 1
      html_escape = options[:html_escape] || 1
      snippet_prefix = options[:snippet_prefix] || "..."
      snippet_suffix = options[:snippet_suffix] || "..."

      snippet_query = keywords.collect { |keyword|
        "'#{keyword}', '#{keyword_prefix}', '#{keyword_suffix}'"
      }
      snippet_query = snippet_query.join(', ')

      snippets = snippet_columns.split(',').collect { |column|
        "mroonga_snippet(#{column},
        #{max_bytes}, #{max_count},
        '#{encoding}',
        #{skip_leading_spaces}, #{html_escape},
        '#{snippet_prefix}', '#{snippet_suffix}',
        #{snippet_query}
        ) AS #{column}"
      }

      columns = attribute_names - snippet_columns.split(',')
      columns << snippets
      select(columns)
    end
    def self.mrn_escape_query(query)
      query = query.gsub(/"/, "\\\\\"")
      query = query.gsub(/'/, "\\\\'")
      query = query.gsub(/\(/, "\\\\\\(")
      query = query.gsub(/\)/, "\\\\\\)")
      query = query.gsub(/>/, "\\\\\\>")
      query = query.gsub(/</, "\\\\\\<")
    end
    def self.mrn_extract_keywords(query)
      return nil if query.nil?
      query = query.gsub(/'/, "''")
      phrases = query.scan(/"[^"]*"/)
      phrases = phrases.collect do |phrase|
        phrase.gsub(/"/, "")
      end
      phrases.delete("")
      query_excluded_phrases = query.gsub(/"[^"]*"/, '')
      words = query_excluded_phrases.split(/[　\s+-\\*()]+/)
      words.delete("OR")
      words.delete("")

      words + phrases
    end
  end
end
