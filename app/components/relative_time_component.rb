# frozen_string_literal: true

class RelativeTimeComponent < ViewComponent::Base
  def initialize time:
    @time = time
  end

  def relative_word
    distance_of_time_in_words_to_now @time
  end

  def human_exact
    @time.to_s :long_ordinal
  end

  def machine_exact
    @time.rfc2822
  end
end
