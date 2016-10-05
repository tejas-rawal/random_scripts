require 'csv'

# raw_pay_records_file = ExternalData::AssalEnterprise::Payroll.raw_pay_records('2015-05-17')
# output_file = File.open('/Users/tejasrawal/Desktop/raw_records_05_17.csv', 'w')
#
# CSV.parse(raw_pay_records_file).each do |row|
#   output_file << row.join(',') + "\n"
# end

clock_records = ExternalData::AssalEnterprise::Clock.select('clk_empname, clk_corpid, clk_storeid, clk_jobid, clk_timein, clk_timeout, clk_hours, clk_rate').where('clk_date = ?', '2016-09-05')
output_file = CSV.open('/data/home/shared/labor_day_hours.csv', 'wb') do |csv|
  csv << ['Employee', 'Employee ID', 'Store', 'Job ID', 'Time In', 'Time Out', 'Total Hours', 'Rate']
  clock_records.each do |record|
    employee_id = record.clk_corpid.present? ? record.clk_corpid : 'Missing'
    store = Store::Location.where('store_number = ?', record.clk_storeid).first.initials

    csv << [record.clk_empname, employee_id, store, record.clk_jobid, record.clk_timein.strftime('%r'), record.clk_timeout.strftime('%r'), record.clk_hours, record.clk_rate]
  end
end

# clock_records = ExternalData::AssalEnterprise::Clock.select('clk_empname, clk_jobid, clk_deptid, clk_timein, clk_timeout, clk_hours, clk_rate').where('clk_storeid = ? and clk_date = ?', 01, '2015-07-15')
# output_file = CSV.open('/data/home/shared/lw_hours.csv', 'wb') do |csv|
#   csv << ['Employee Name', 'Job ID', 'Department ID', 'Time In', 'Time Out', 'Total Hours', 'Rate']
#   clock_records.each do |record|
#     csv << [record.clk_empname, record.clk_jobid, record.clk_deptid, record.clk_timein.strftime('%r'), record.clk_timeout.strftime('%r'), record.clk_hours, record.clk_rate]
#   end
# end

# clock_records = ExternalData::AssalEnterprise::Clock.select('clk_date, clk_empname, clk_corpid, clk_storeid, clk_jobid, clk_deptid, clk_timein, clk_timeout, clk_hours, clk_rate').where('clk_corpid = ? and clk_date between ? and ?', '90478', '2015-05-18', '2015-05-31')
# output_file = CSV.open('/data/home/shared/employee_timeclock_report.csv', 'wb') do |csv|
#   csv << ['Date', 'Employee', 'Employee ID', 'Store', 'Job ID', 'Department', 'Time In', 'Time Out', 'Total Hours', 'Rate']
#   clock_records.each do |record|
#     store = Store::Location.where('store_number = ?', record.clk_storeid).first.initials
#
#     csv << [record.clk_date.strftime('%D'), record.clk_empname, record.clk_corpid, store, record.clk_jobid, record.clk_deptid, record.clk_timein.strftime('%r'), record.clk_timeout.strftime('%r'), record.clk_hours, record.clk_rate]
#   end
# end

# clock_records = ExternalData::AssalEnterprise::Clock.select('clk_date, clk_timein, clk_timeout, clk_hours, clk_brkpaid, clk_brkunpaid').where('clk_corpid = ? and clk_storeid = ? and clk_date between ? and ?', '89504', 33, Date.new(2014, 02, 24), Date.today)
#
# output_file = CSV.open('/data/home/shared/gregory_claggett_records.csv', 'wb') do |csv|
#   csv << ['Date', 'Time In', 'Time Out', 'Total Hours', 'Paid Break', 'Unpaid Break']
#   clock_records.each do |record|
#     csv << [record.clk_date.strftime('%D'), record.clk_timein.strftime('%r'), record.clk_timeout.strftime('%r'), record.clk_hours, record.clk_brkpaid, record.clk_brkunpaid]
#   end
# end

# service_requests = ServiceRequest::Request.includes(:user_profile).select('user_profile_id, created_at, summary').where('created_at >= ? and store_location_id = ?', '2016-06-29', '32')
# output_file = CSV.open('/data/home/shared/finance_tickets.csv', 'wb') do |csv|
#   csv << ['Date', 'Creator', 'Content']
#   service_requests.each do |req|
#     csv << [req.created_at.strftime('%D'), req.user_profile.full_name, req.summary]
#   end
# end