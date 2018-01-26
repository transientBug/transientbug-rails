module ActiveRecordUpsert
  def upsert *attributes
    find_or_create_by(*attributes)
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    retry # YOLO
  end
end
