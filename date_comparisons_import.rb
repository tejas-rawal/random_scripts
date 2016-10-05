require 'csv'

# filepath = '/Users/tejasrawal/Desktop/corresponding_dates.csv'
filepath = '/data/home/shared/corresponding_dates.csv'
records = CSV.read(filepath, 'rb').slice(1..-1)

records.each do |row|
  DateComparison.new.tap do |u|
    u.current_date = Date.parse(row[0]) if row[0].present?
    u.last_year_date = Date.parse(row[4]) if row[4].present?
    
    u.save
  end
end