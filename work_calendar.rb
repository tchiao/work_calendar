require 'date'

module WorkCalendar
  class Configuration
    attr_accessor :weekdays, :holidays

    def initialize
      @weekdays = []
      @holidays = []
    end
  end

  class << self
    attr_accessor :config

    def configure
      self.config ||= Configuration.new
      yield(config)
    end

    def active?(date)
      !holiday?(date) && in_weekdays?(date)
    end

    def days_before(i, date)
      raise ArgumentError if i < 0

      while i > 0
        date -= 1
        i -= 1 if active?(date)
      end
      date
    end

    def days_after(i, date)
      raise ArgumentError if i < 0

      while i > 0
        date += 1
        i -= 1 if active?(date)
      end
      date
    end

    def between(start_date, end_date)
      raise ArgumentError if start_date > end_date

      dates = []
      while start_date < end_date
        dates << start_date if active?(start_date)
        start_date += 1
      end
      dates
    end

    private

    def holiday?(date)
      self.config.holidays.include?(date)
    end

    def in_weekdays?(date)
      self.config.weekdays.include?(date_to_weekday_sym(date))
    end

    def date_to_weekday_sym(date)
      Date::ABBR_DAYNAMES[date.wday].downcase.to_sym
    end
  end
end
