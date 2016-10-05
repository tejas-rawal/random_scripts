emp_wsdl =  "https://services.hotschedules.com/api/services/EmpService?wsdl"
emp_service = HotSchedulesWebService::Services::EmployeeService.new(emp_wsdl)

# response = emp_service.store_jobs(1)
# response = emp_service.store_employees(1)
# response = emp_service.emp_jobs(10)
# response = emp_service.set_employees(42)
# response = emp_service.set_emp_jobs(33)
# response = lincolnwood_emps.terminate_employees(1)

# client = Savon.client do
#   wsdl emp_wsdl
#   wsse_auth ENV['HS_USERNAME'], ENV['HS_PASSWORD']
#   pretty_print_xml true
#   env_namespace :soapenv
# end


emp1 = {:clientId=>ENV["CLIENT_ID"], :empNum=>"559", "FName"=>"Lisa", :hsId=>"100", "LName"=>"Maldonado", :status=>"1", :storeNum=>7}

response = emp_service.client.call(:set_emps, soap_action: false) do
  message(concept: ENV['CONCEPT'], storeNum: 7, emps: {item: [emp1]})
end

# puts response

#######################################################################################################################################################

# time_wsdl = "https://services.hotschedules.com/api/services/TimeCardService?wsdl"
# lincolnwood_times = HotScheduleService::TimeCardService.new(time_wsdl)

# response = lincolnwood_times.set_time_cards(1, '2015-02-03', '2015-02-03')
# response = lincolnwood_times.get_time_cards(1, '2014-11-10', '2014-11-14')

# STORE = 33 # Gold Coast

# client = Savon.client do
#   wsdl time_wsdl
#   wsse_auth ENV['HS_USERNAME'], ENV['HS_PASSWORD']
#   pretty_print_xml true
#   env_namespace :soapenv
# end
#
# timecards = HotSchedulesWebService::Models::Timecard.new(STORE).timecards('2016-06-16', '2016-06-17').delete_if { |x| x.nil? }
#
# response = client.call(:set_time_cards, soap_action: false) do
#   message(concept: ENV['CONCEPT'], storeNum: STORE, cards: {item: timecards}, start: '2016-06-16', end: '2016-06-17')
# end
#
# puts response.body

#######################################################################################################################################################

# sal_wsdl = "http://services.hotschedules.com/api/services/SalesService?wsdl"
# sales_service = HotScheduleService::SalesItemService.new(sal_wsdl)

# response = lincolnwood_sales.get_rvc(1)
# response = lincolnwood_sales.sales_cats(1)
# response = sales_service.set_sales(1, '2015-04-11')

# client = Savon.client do
#   wsdl sal_wsdl
#   wsse_auth HS_USERNAME, HS_PASSWORD
#   pretty_print_xml true
#   env_namespace :soapenv
# end
#
# sales_arr = [{clientId: CLIENT_ID, rvc: 1, salesCat: 1, storeNum: 1, ttl: 5587.25, businessDate: '2014-11-25', dateTime: '2014-11-25'}]
# response = client.call(:set_sales_items, soap_action: false) do
#   message(concept: CONCEPT, storeNum: 1, sales: {item: sales_arr}, start: '2014-11-25', end: '2014-11-25')
# end

# puts response.body

#######################################################################################################################################################
# sched_wsdl = "https://services.hotschedules.com/api/services/ScheduleService?wsdl"
# rn_sched = HotScheduleService::ScheduleService.new(sched_wsdl)
#
# response = rn_sched.schedule_items(6, '2015-10-11', '2015-10-11')
#
# puts response

#######################################################################################################################################################

# require 'benchmark'
#
# client = HotScheduleService::EmployeeService.new(ENV['EMP_SERVICE'])
#
# Store::Location.where("store_number > 0").each do |store|
#   Benchmark.bm do |x|
#     x.report { client.store_jobs(store.store_number) }
#   end
# end