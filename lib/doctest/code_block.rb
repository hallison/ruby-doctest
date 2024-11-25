module DocTest
  # A +CodeBlock+ is a group of one or more ruby statements, followed by an optional result.
  # For example:
  #  >> a = 1 + 1
  #  >> a - 3
  #  => -1
  class CodeBlock
    attr_reader :statements, :result, :passed
    
    def initialize(statements = [], result = nil)
      @statements = statements
      @result = result
    end
    
    # === Tests
    #
    # probe: Single statement with result should pass
    # >> ss = [DocTest::Statement.new([">> a = 1"])]
    # >> r = DocTest::Result.new(["=> 1"])
    # >> cb = DocTest::CodeBlock.new(ss, r)
    # >> cb.pass?
    # => true
    #
    # check: Single statement without result should pass by default
    # >> ss = [DocTest::Statement.new([">> a = 1"])]
    # >> cb = DocTest::CodeBlock.new(ss)
    # >> cb.pass?
    # => true
    #
    # try: Multi-line statement with result should pass
    # >> ss = [DocTest::Statement.new([">> a = 1"]),
    #          DocTest::Statement.new([">> 'a' + a.to_s"])]
    # >> r = DocTest::Result.new(["=> 'a1'"])
    # >> cb = DocTest::CodeBlock.new(ss, r)
    # >> cb.pass?
    # => true
    def pass?
      if @computed
        @passed
      else
        @computed = true
        @passed =
          begin
            actual_results = @statements.map{ |s| s.evaluate }
            @result ? @result.matches?(actual_results.last) : true
          end
      end
    end
    
    def actual_result
      @statements.last.actual_result
    end
    
    def expected_result
      @result.expected_result
    end
    
    def lines
      @statements.map{ |s| s.lines }.flatten +
      @result.lines
    end
  end
end
