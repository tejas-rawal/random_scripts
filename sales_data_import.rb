require 'date'

START = Date.new(2014, 3, 13) # date of first sales record in enterprise
STORE = 1 #Lincolnwood

date = START

while date < Date.today
  
  # system "bundle exec rake sale:set_sales_for_store[1]"
  
  client = HotScheduleService::SalesItemService.new(ENV['SALES_SERVICE'])
  client.set_sales(STORE, date.iso8601)
  
  date += 1
end