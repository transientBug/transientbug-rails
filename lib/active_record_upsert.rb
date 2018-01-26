module ActiveRecordUpsert
  def upsert *attributes
    begin
      find_or_create_by(*attributes)
    rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
      retry # YOLO
    end
  end
end
