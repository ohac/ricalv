require 'rubygems'
require 'icalendar'
require 'fileutils'
require 'digest'

# FIXME monkey patch for icalendar 1.1.0
module Icalendar

  class RRule

    def to_ical
      result = ["FREQ=#{@frequency}"]
      result << ";UNTIL=#{@until.to_ical}" if @until
      result << ";COUNT=#{@count}" if @count
      result << ";INTERVAL=#{@interval}" if @interval
      @by_list.each do |key, value|
        result << ";#{key.to_s.upcase}=#{value[0]}" if value
      end
      result << ";WKST=#{@wkst}" if @wkst
      result.join
    end

  end

end

WEEKTABLE = { 'SU' => 7, 'MO' => 1, 'TU' => 2,
              'WE' => 3, 'TH' => 4, 'FR' => 5, 'SA' => 6 }
KEYS = [ 'FREQ', 'BYDAY', 'BYMONTH', 'WKST', 'UNTIL', 'INTERVAL' ]
WEEKTOSTR = { 0 => 'Sun', 1 => 'Mon', 2 => 'Tue', 3 => 'Wed', 4 => 'Thu',
    5 => 'Fri', 6 => 'Sat' }

today = Date.today
date_end = today + 365 * 3

HOME = ENV['HOME']
SETTING = "#{HOME}/.ricalvrc"
CACHEDIR = "#{HOME}/.ricalv.d/cache"
unless File.exists?(SETTING)
  puts "no #{SETTING}"
  exit 1
end
icss = File.open(SETTING) { |f| f.readlines.map(&:chop) }
icss = icss.map { |fn|
  case fn
  when /\A\z/
  when /^#/
    nil
  when /^\//
    fn
  when /http:\/\//
    FileUtils.mkdir_p(CACHEDIR)
    d = CACHEDIR + '/' + Digest::MD5.hexdigest(fn)
    `wget -q -O #{d} #{fn}`
    d
  else
    HOME + '/' + fn
  end
}.select{|ics| !ics.nil?}

calss = icss.map { |fn|
  File.open(fn) { |f| Icalendar.parse(f) }
}

items = calss.map { |cals|
  cals.map { |cal|
    cal.events.map { |event|
      lines = []
      d = Date.parse(event.dtstart.to_s)
      lines << { :d => d, :e => event }
      rrule = event.properties["rrule"]
      if rrule
        rulehash = {}
        rule = rrule[0].to_ical # TODO for icalendar 1.1.0
        rule = rule.split(";")
        rule.each do |item|
          a, b = item.split("=")
          rulehash[a] = b
        end
        yearly = false
        ud = date_end
        mon = nil
        day = nil
        week = nil
        KEYS.each do |key|
          v = rulehash[key]
          next unless v
          case key
          when 'WKST'
            next
          when 'FREQ'
            yearly = true
          when 'UNTIL'
            ud = Date.parse(v)
          when 'INTERVAL'
            v = v.to_i
            next if v == 1
            v = "interval #{v}"
          when 'BYMONTH'
            next unless rulehash.has_key?('BYDAY')
            mon = v.to_i
          when 'BYDAY'
            day = v[0,1].to_i
            week = WEEKTABLE[v[1,2]]
          else
          end
        end
        if yearly
          d = d.next_year # TODO for ruby1.9
          d = Date.new(d.year, mon, 1) if mon
          while d <= ud
            if day
              d += 1 while d.cwday != week
              d += (day - 1) * 7
            end
            lines << { :d => d, :e => event }
            d = d.next_year
            d = Date.new(d.year, mon, 1) if mon
          end
        end
      end
      lines
    }
  }
}.flatten

items << {:d => today, :t => '*** TODAY ***'}

items = items.select{|v|
  d = v[:d]
  d.year == today.year && d.month == today.month
}
items = items.map{|v| "#{v[:d].to_s}(#{WEEKTOSTR[v[:d].wday]}) #{v[:t] || v[:e].summary}"}
items.sort.each{|v| puts v}
