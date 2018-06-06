class ApplicationSearcher
  attr_reader :errors, :includes, :results
  include Enumerable

  def initialize
    @errors = Errors.new
  end

  def includes *data
    @includes = data
    self
  end

  def objects
    fail NotImplementedError
  end

  def each
    objects.each
  end

  def search params
    @results = query_search params[:q]

    self
  end

  def query query
    @results = @results.query query

    self
  end
end
