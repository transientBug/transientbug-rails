module Api::V1Helper
  # Kaminari doesn't provide helpers for absolute URLs to pagination for use in
  # JSON API spec pagination.
  def url_to_next_page scope, **options
    return unless scope.next_page

    url_for options.merge(params: { page: scope.next_page }, only_path: false)
  end

  def url_to_prev_page scope, **options
    return unless scope.prev_page

    url_for options.merge(params: { page: scope.prev_path }, only_path: false)
  end

  def url_to_first_page scope, **options
    return unless scope.total_pages.positive?

    url_for options.merge(params: { page: 1 }, only_path: false)
  end

  def url_to_last_page scope, **options
    return unless scope.total_pages.positive?

    url_for options.merge(params: { page: scope.total_pages }, only_path: false)
  end

  def url_to_current_page scope, **options
    url_for options.merge(params: { page: scope.current_page }, only_path: false)
  end
end
