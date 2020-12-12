# frozen_string_literal: true

SimpleCov.start do
  enable_coverage :branch
  add_filter %r{^/spec/}
  add_filter do |source_file|
    source_file.lines.count < 5
  end
end
