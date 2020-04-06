class ZobBuilder
  def on **events
    events.each_with_object({}) do |(key, value), memo|
      memo[:"zob-on:#{ key }"] = value
    end
  end

  def bind **attributes
    attributes.each_with_object({}) do |(key, value), memo|
      memo[:"zob-bind:#{ key }"] = key.to_s == "class" ? value.to_json : value
    end
  end
end

module ZobHelper
  def zob behavior=nil, **opts
    return ZobBuilder.new unless behavior

    zob_args = opts.each_with_object({}) do |(key, value), memo|
      memo["arg:#{ key }"] = value
    end

    zob_data = {
      behavior: behavior,
    }.merge(zob_args)

    zob_data[:behavior] = behavior

    data = zob_data.transform_keys { |key| :"zob-#{ key }" }

    return data unless block_given?

    capture do
      yield data
    end
  end
end
