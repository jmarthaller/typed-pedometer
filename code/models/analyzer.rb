# typed: true
require_relative 'user'
require_relative 'trial'

class Analyzer
  extend T::Sig

  THRESHOLD = T.let(0.09, Float)

  attr_reader :steps, :delta, :distance, :time

  def self.run(data, user, trial)
    analyzer = Analyzer.new(data, user, trial)
    analyzer.measure_steps
    analyzer.measure_delta
    analyzer.measure_distance
    analyzer.measure_time
    analyzer
  end

  # sig {params(data: Data, user: User, trial: Trial).void}
  def initialize(data, user, trial)
    @data  = data
    @user  = user
    @trial = trial
  end

  # sig {(count_steps: T::Boolean).returns(T::Boolean)}
  def measure_steps
    @steps = 0
    count_steps = T.let(true, T::Boolean)

    @data.each_with_index do |data, i|
      if (data >= THRESHOLD) && (@data[i-1] < THRESHOLD)
        next unless count_steps

        @steps += 1
        count_steps = false
      end

      count_steps = true if (data < 0) && (@data[i-1] >= 0)
    end
  end

  def measure_delta
    @delta = @steps - @trial.steps if @trial.steps
  end

  def measure_distance
    @distance = @user.stride * @steps
  end

  def measure_time
    @time = @data.count/@trial.rate if @trial.rate
  end

end