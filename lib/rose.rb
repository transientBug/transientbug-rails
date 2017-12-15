class Rose
  def initialize partitions:, range:, rollover: false
    @partitions = partitions
    @range = range
    @rollover = rollover

    range_diff = range.max - range.min

    @divisions = range_diff.to_f / partitions.length
  end

  def partition num
    normalized = num - @range.min

    if normalized < 0
      return @partitions.last if @rollover
      return @partitions.first
    end

    partition = @partitions[ (normalized / @divisions).round ]

    return partition unless partition.nil?
    return @partitions.last unless @rollover
    @partitions.first
  end

  def to_s
    @partitions.map.with_index do |section, idx|
      "#{ @divisions * idx }:#{ section }"
    end.join " "
  end
end

class CompassRose
  COMPASS_DIRECTIONS = [
    "north",
    "north north east",
    "north east",
    "east north east",
    "east",
    "east south east",
    "south east",
    "south south east",
    "south",
    "south south west",
    "south west",
    "west south west",
    "west",
    "west north west",
    "north west",
    "north north west"
  ].freeze

  ROSE = Rose.new(partitions: COMPASS_DIRECTIONS, range: 0..360, rollover: true)

  def self.direction bearing
    ROSE.partition bearing
  end
end

class TempRose
  WORDING = [
    "cold as balls",
    "cold",
    "chilly",
    "fairly okay",
    "warm",
    "hot",
    "hot as fuck"
  ].freeze

  ROSE = Rose.new(partitions: WORDING, range: 32..110, rollover: false)

  def self.word temp
    ROSE.partition temp
  end
end

class PrecipRose
  WORDING = [
    "most likely dry",
    "probably dry",
    "questionably dry",
    "questionably wet",
    "probably wet",
    "supawet",
  ].freeze

  ROSE = Rose.new(partitions: WORDING, range: 0..1, rollover: false)

  def self.word amount
    ROSE.partition amount
  end
end
