class ZobBuilder
  def on **events
    zob_vents = events.each_with_object({}) do |(key, value), memo|
      memo["on:#{ key }"] = value
    end

    { zob: zob_vents }
  end

  def bind **attributes
    zob_vents = attributes.each_with_object({}) do |(key, value), memo|
      memo["bind:#{ key }"] = key.to_s == "class" ? value.to_json : value
    end

    { zob: zob_vents }
  end
end

module ZobHelper
  def zob behavior=nil, **opts
    return ZobBuilder.new unless behavior

    zob_data = { behavior: behavior, args: opts }

    zob_data[:behavior] = behavior

    data = { zob: zob_data }

    return data unless block_given?

    capture do
      yield data
    end
  end
end
