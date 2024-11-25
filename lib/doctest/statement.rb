module DocTest
  class EvaluationError < Exception
    attr_reader :statement, :original_exception

    def initialize(statement, original_exception)
      @statement, @original_exception = statement, original_exception
    end
  end

  class Statement < Lines
    attr_reader :actual_result

    # === Tests
    # 
    # doctest: The FILENAME ruby constant should be replaced by the name of the file
    # >> __FILE__[/statement\.rb$/]
    # => "statement.rb"
    def initialize(doc_lines, line_index = 0, file_name = nil)
      @file_name = file_name
      super(doc_lines, line_index)
    end

    # === Tests
    # 
    # doctest: A statement should parse out a '>>' irb prompt
    # >> s = DocTest::Statement.new([">> a = 1"])
    # >> s.source_code
    # => "a = 1"
    #
    # doctest: More than one line should get included, if indentation so indicates
    # >> s = DocTest::Statement.new([">> b = 1 +", " 1", "not part of the statement"])
    # >> s.source_code
    # => "b = 1 +\n1"
    #
    # doctest: Lines indented by ?> should have the ?> removed.
    # >> s = DocTest::Statement.new([">> b = 1 +", "?> 1"])
    # >> s.source_code
    # => "b = 1 +\n1"
    def source_code
      lines.first =~ /^#{Regexp.escape(indentation)}>>\s(.*)$/
      first = [$1]
      remaining = (lines[1..-1] || [])
      (first + remaining).join("\n")
    end

    # === Test
    #
    # doctest: Evaluating a multi-line statement should be ok
    # >> s = DocTest::Statement.new([">> b = 1 +", " 1", "not part of the statement"])
    # >> s.evaluate
    # => 2
    #
    # doctest: Evaluating a syntax error should raise an EvaluationError
    # >> s = DocTest::Statement.new([">> b = 1 +"])
    # >> begin s.evaluate; :fail; rescue DocTest::EvaluationError; :ok end
    # => :ok
    def evaluate
      sc = source_code.gsub("__FILE__", @file_name.inspect)
      if Configuration.verbose
        puts "EVAL: #{sc}"
      end
      @actual_result = eval(sc, TOPLEVEL_BINDING, __FILE__, __LINE__)
      if Configuration.verbose
        puts "RESULT: #{@actual_result}"
      end
      @actual_result
    rescue Exception => e
      if Configuration.trace
        raise e.class, e.to_s + "\n" + e.backtrace.first
      else
        raise EvaluationError.new(self, e)
      end
    end
  end
end
