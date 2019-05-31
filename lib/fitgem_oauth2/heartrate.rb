module FitgemOauth2
  class Client

    HR_PERIODS = %w[1d 7d 30d 1w 1m].freeze
    HR_DETAIL_LEVELS = %w[1sec 1min].freeze

    def hr_series_for_date_range(start_date, end_date)
      validate_start_date(start_date)
      validate_end_date(end_date)

      url = ['user', user_id, 'activities/heart/date', format_date(start_date), format_date(end_date)].join('/')
      get_call(url + '.json')
    end

    def hr_series_for_period(start_date, period)
      validate_start_date(start_date)
      validate_hr_period(period)

      url = ['user', user_id, 'activities/heart/date', format_date(start_date), period].join('/')
      get_call(url + '.json')
    end

    # retrieve heartrate time series
    def heartrate_time_series(start_date: nil, end_date: nil, period: nil)
      warn '[DEPRECATION] `heartrate_time_series` is deprecated.  Please use `hr_series_for_date_range` or `hr_series_for_period` instead.'

      regular_time_series_guard(
        start_date: start_date,
        end_date: end_date,
        period: period
      )

      second = period || format_date(end_date)

      url = ['user', user_id, 'activities/heart/date', format_date(start_date), second].join('/')

      get_call(url + '.json')
    end

    # retrieve intraday series for heartrate
    def intraday_heartrate_time_series(start_date: nil, end_date: nil, detail_level: nil, start_time: nil, end_time: nil)
      intraday_series_guard(
        start_date: start_date,
        end_date: end_date,
        detail_level: detail_level,
        start_time: start_time,
        end_time: end_time
      )

      end_date = format_date(end_date) || '1d'

      url = ['user', user_id, 'activities/heart/date', format_date(start_date), end_date, detail_level].join('/')

      if start_time && end_time
        url = [url, 'time', format_time(start_time), format_time(end_time)].join('/')
      end

      get_call(url + '.json')
    end

    private

    def validate_hr_period(period)
      raise FitgemOauth2::InvalidArgumentError, "Invalid period: #{period}. Valid periods are #{HR_PERIODS}." unless period && HR_PERIODS.include?(period)
    end

    def regular_time_series_guard(start_date:, end_date:, period:)
      validate_start_date(start_date)

      raise FitgemOauth2::InvalidArgumentError, 'Both end_date and period specified. Specify only one.' if end_date && period

      raise FitgemOauth2::InvalidArgumentError, 'Neither end_date nor period specified. Specify at least one.' if !end_date && !period

      validate_hr_period(period) if period
    end

    def intraday_series_guard(start_date:, end_date:, detail_level:, start_time:, end_time:)
      raise FitgemOauth2::InvalidArgumentError, 'Start date not provided.' unless  start_date

      raise FitgemOauth2::InvalidArgumentError, "Please specify the defail level. Detail level should be one of #{HR_DETAIL_LEVELS}." unless detail_level && HR_DETAIL_LEVELS.include?(detail_level)

      raise FitgemOauth2::InvalidArgumentError, 'Either specify both the start_time and end_time or specify neither.' if (start_time && !end_time) || (end_time && !start_time)
    end
  end
end
