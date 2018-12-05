require 'Time' unless defined?(Time::RFC2822_DAY_NAME)

class VisionaTime < Time

    # 2000/01/01 Midnight
    JULIAN_DATE_OF_VCUB1_EPOCH  = 2451544.5

    def initialize

      super
    end

    def self.mdy2visiona(year, month, day, hour, minute, second, us)

      ms  = (hour * MSEC_PER_HOUR) + (minute * MSEC_PER_MINUTE) + (second * MSEC_PER_SECOND) + (us / USEC_PER_MSEC)
      us  = us % USEC_PER_MSEC
      jd  = Time.mdy2julian(year, month, day, 0, 0, 0, 0)
      day = (jd - JULIAN_DATE_OF_VCUB1_EPOCH).round

      return [day, ms, us]
    end

    def self.visiona2mdy(day, ms, us)

      jdate = day + JULIAN_DATE_OF_VCUB1_EPOCH
      year, month, day, hour, minute, second, _ = Time.julian2mdy(jdate)
      hour = (ms / MSEC_PER_HOUR).to_i
      temp = ms - (hour * MSEC_PER_HOUR)
      minute = (temp / MSEC_PER_MINUTE).to_i
      temp -= minute * MSEC_PER_MINUTE
      second = temp / MSEC_PER_SECOND
      temp -= second * MSEC_PER_SECOND
      us = us + (temp * USEC_PER_MSEC)

      return [year, month, day, hour, minute, second, us]
    end

    def self.julian2visiona(jdate)

      day = jdate - JULIAN_DATE_OF_VCUB1_EPOCH
      fraction = day % 1.0
      day = day.to_i
      ms  = fraction * MSEC_PER_DAY_FLOAT
      fraction = ms % 1.0
      ms = ms.to_i
      us = fraction * USEC_PER_MSEC
      us = us.to_i

      return [day, ms, us]
    end

    def self.visiona2julian(day, ms, us)

      (day + JULIAN_DATE_OF_VCUB1_EPOCH) + ((ms.to_f + (us / 1000.0)) / MSEC_PER_DAY_FLOAT)
    end

    def self.sec2visiona(sec, sec_epoch_vis = JULIAN_DATE_OF_VCUB1_EPOCH)

      self.julian2visiona((sec / SEC_PER_DAY_FLOAT) + sec_epoch_vis)
    end

    def self.visiona2sec(day, ms, us, sec_epoch_vis = JULIAN_DATE_OF_VCUB1_EPOCH)

      (self.visiona2julian(day, ms, us) - sec_epoch_vis) * SEC_PER_DAY_FLOAT
    end
end