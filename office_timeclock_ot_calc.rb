require 'csv'
require 'date'

CONNECTION = ActiveRecord::Base.establish_connection(
  :adapter => 'mysql',
  :database => 'inside_prod',
  :host => 'konner.loumalnatis.com',
  :username => 'root',
  :password => '3nch1lada'
)
OLD_START_DATE = Date.new(2016, 02, 15)
OLD_END_DATE = Date.new(2016, 02, 21)
NEW_START_DATE = Date.new(2016, 02, 18)
NEW_ADJUSTED_START = Date.new(2016, 02, 22)
NEW_END_DATE = Date.new(2016, 02, 24)
old_week_ot_hours = Hash.new
new_week_ot_hours = Hash.new
OUTPUT_FILE = '/u/apps/new_inside/shared/timeclock_ot_hours.csv'

# query results mapping
MANAGER_ID = 0
DATE = 3
TOTAL_SECONDS = 4
JOB_FUNC_ID = 5

def retrieve_hours(start_date, record_date, hours_hash)
  accumulated_hours = Hash.new
  sql_query = "select manager_id, time_in, time_out, date, total, job_function_id from work_records where audit_state not in ('replaced', 'rejected') and needs_approval = '0' and date = '#{record_date.strftime}' order by time_in"
  CONNECTION.connection.execute(sql_query).each do |row|
    accumulated_hours[row[MANAGER_ID]] ||= start_date == record_date ? 0.0 : sum_hours(row[MANAGER_ID], start_date, record_date - 1.day).to_f

    if hours_hash[row[MANAGER_ID]]
      hours_hash[row[MANAGER_ID]] << format_record(row[DATE], row[JOB_FUNC_ID], (row[TOTAL_SECONDS].to_f / 3600.0).to_f)
    else
      accumulated_hours[row[MANAGER_ID]] += (row[TOTAL_SECONDS].to_f / 3600.0).to_f
      if accumulated_hours[row[MANAGER_ID]] > 40.0
        hours_hash[row[MANAGER_ID]] = [format_record(row[DATE], row[JOB_FUNC_ID], (accumulated_hours[row[MANAGER_ID]] - 40.0).to_f)]
      end
    end
  end
  hours_hash
end

def sum_hours(manager_id, start_date, end_date)
  sum = 0.0
  sql = "select manager_id, time_in, time_out, date, total from work_records where manager_id = '#{manager_id}' and audit_state not in ('replaced', 'rejected') and needs_approval = '0' and date between '#{start_date.strftime}' and '#{end_date.strftime}'"
  CONNECTION.connection.execute(sql).each do |row|
    sum += (row[TOTAL_SECONDS].to_f / 3600.0).to_f
  end

  sum
end

def format_record(record_date, job_func, hours)
  {
    :date => record_date,
    :job_function => job_func,
    :hours => hours
  }
end

def combine_ot_hours(old_week_hours = {}, new_week_hours = {})
  old_week_hours.merge(new_week_hours) { |manager_id, orig_arr, new_arr| (orig_arr << new_arr).flatten }
end

(OLD_START_DATE..OLD_END_DATE).each do |date|
  retrieve_hours(OLD_START_DATE, date, old_week_ot_hours)
end

(NEW_ADJUSTED_START..NEW_END_DATE).each do |date|
  retrieve_hours(NEW_START_DATE, date, new_week_ot_hours)
end

combined = combine_ot_hours(old_week_ot_hours, new_week_ot_hours)

CSV.open(OUTPUT_FILE, 'wb') do |csv|
  csv << ['Employee Id', 'Date', 'Job Function', 'Overtime Hours']
  combined.each do |manager_id, ot_array|
    csv << [manager_id]
    ot_array.each do |obj|
      csv << ['', obj[:date], obj[:job_function], obj[:hours]]
    end
    csv << "\n"
  end
end
