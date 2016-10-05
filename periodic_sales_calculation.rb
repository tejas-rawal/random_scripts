# Sales by period
STORE = Store::Location.where(initials: 'LP').take
START = Date.new(2014, 3, 12)
ASSAL_SALES = ExternalData::AssalEnterprise::Sale

# Array Indices
YEAR = 0
PERIOD_ID = 1
SALES = 3

filepath = '/Users/tejasrawal/Documents/LP_periodic_dine_in_sales.csv'
# filepath = '/data/home/shared/LP_periodic_dine_in_sales.csv'

def find_period(date)
  Store::Labor::Period.locate_period(date).take
end

def period_dine_in_sales(period)
  ASSAL_SALES.for_store(STORE.store_number).for_date_range(period.start_date, period.end_date).sum(ASSAL_SALES::DINING_SALES)
end

periods = (START..Date.yesterday).map { |date| find_period(date) }.uniq

sales_hash = periods.each_with_object({}) do |period, hsh|
  hsh[period] = period_dine_in_sales(period)
end

CSV.open(filepath, 'wb') do |csv|
  csv << ['Year', 'Period', 'Sales']
  sales_hash.each do |period, sales|
    csv << [period.year, period.period, sales.to_f]
  end
end