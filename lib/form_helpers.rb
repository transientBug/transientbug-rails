module FormHelpers
  def errors_for field
    has_error = object.errors.key? field
    messages = object.errors[field]

    field_capture = @template.capture do
      yield(has_error, messages)
    end

    @template.concat field_capture
  end
end
