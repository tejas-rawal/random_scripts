require 'csv'

# periods_file = '/Users/tejasrawal/Desktop/finance_periods_restructured.csv'
# periods_file = '/data/home/shared/finance_periods_restructured.csv'
# periods_file = '/Users/tejasrawal/Documents/finance_periods_2.csv'
periods_file = '/data/home/shared/finance_periods_2.csv'

CSV.foreach(periods_file) do |row|
  # s_m, s_d, s_y = row[2].split(/\//)
  # e_m, e_d, e_y = row[3].split(/\//)
  # s_y = "20#{s_y}"
  # e_y = "20#{e_y}"

  Store::Labor::Period.where(year: row[1].to_i, period: row[0].to_i).first_or_create.tap do |p|
    # p.period = row[0].to_i
    # p.year = row[1].to_i
    # p.start_date = Date.new(s_y.to_i, s_m.to_i, s_d.to_i)
    p.start_date = Date.strptime(row[2], '%m/%d/%y')
    # p.end_date = Date.new(e_y.to_i, e_m.to_i, e_d.to_i)
    p.end_date = Date.strptime(row[3], '%m/%d/%y')
    
    p.save
  end
end