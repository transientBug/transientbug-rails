class ApplicationSearcher
  attr_reader :errors, :results

  def initialize
    @errors = Errors.new
  end

  def objects
    @results.objects
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
