ORIGINAL_START = Date.new(2016, 02, 15)
ORIGINAL_END = Date.new(2016, 02, 21)
NEW_WEEK_START = Date.new(2016, 02, 18)
NEW_START = Date.new(2016, 02, 22)
NEW_END = Date.new(2016, 02, 24)
ASSAL_CLOCK = ExternalData::AssalEnterprise::Clock
CLOCK_KEYS = ASSAL_CLOCK::CLOCK_KEYS
OUTPUT_FILE = '/Users/tejasrawal/Desktop/payroll_transition_ot_hours.csv'

def retrieve_hours(start_date, record_date, hours_hash)
  accumulated_hours = Hash.new
  ASSAL_CLOCK.where("#{CLOCK_KEYS[:date]} = ?", record_date).order("#{CLOCK_KEYS[:clock_in]}").each do |clk_record|
    employee_id = clk_record[CLOCK_KEYS[:payroll_id]]
    accumulated_hours[employee_id] ||= start_date == record_date ? 0.0 : sum_hours(employee_id, start_date, record_date - 1.day).to_f

    if hours_hash[employee_id]
      hours_hash[employee_id] << format_clock_record(record_date.iso8601, clk_record[CLOCK_KEYS[:store_id]], clk_record[CLOCK_KEYS[:dept_id]], clk_record[CLOCK_KEYS[:job_id]], clk_record[CLOCK_KEYS[:rate]], clk_record[CLOCK_KEYS[:hours]])
    else
      accumulated_hours[employee_id] += clk_record[CLOCK_KEYS[:hours]].to_f
      if accumulated_hours[employee_id] > 40.0
        hours_hash[employee_id] = [format_clock_record(record_date.iso8601, clk_record[CLOCK_KEYS[:store_id]], clk_record[CLOCK_KEYS[:dept_id]], clk_record[CLOCK_KEYS[:job_id]], clk_record[CLOCK_KEYS[:rate]], (accumulated_hours[employee_id] - 40.0).to_d)]
      end
    end
  end
  hours_hash
end

def sum_hours(emp_id, start_date, end_date)
  ASSAL_CLOCK.for_date_range(start_date, end_date).where("#{CLOCK_KEYS[:payroll_id]} = ?", emp_id).sum("#{CLOCK_KEYS[:hours]}")
end

def format_clock_record(clk_date, store_number, dept, job_id, rate, hours)
  {
    date: clk_date,
    store: store_number,
    department: dept,
    job_id: job_id,
    job_rate: rate,
    hours: hours
  }
end

def combine_ot_hours(original = {}, new_week = {})
  original.merge(new_week) { |emp_id, orig_arr, new_arr| (orig_arr << new_arr).flatten }
end

original_week_ot_hours = Hash.new

(ORIGINAL_START..ORIGINAL_END).each do |date|
  retrieve_hours(ORIGINAL_START, date, original_week_ot_hours)
end

new_week_ot_hours = Hash.new

(NEW_START..NEW_END).each do |date|
  retrieve_hours(NEW_WEEK_START, date, new_week_ot_hours)
end

# Two hashes must be combined
combined = combine_ot_hours(original_week_ot_hours, new_week_ot_hours)

CSV.open(OUTPUT_FILE, 'wb') do |csv|
  csv << ['Employee', 'Date', 'Store', 'Department', 'Job ID', 'Regular Rate', 'Overtime Hours']
  combined.each do |corp_id, ot_array|
    employee_record = ASSAL_CLOCK.where("#{CLOCK_KEYS[:payroll_id]} = ?", corp_id).order("#{CLOCK_KEYS[:date]} desc").first
    employee_header = employee_record ? ["#{employee_record[CLOCK_KEYS[:emp_name]]} (#{corp_id})"] : [corp_id]
    csv << employee_header
    ot_array.each do |obj|
      store_initials = Store::Location.find_by_store_number(obj[:store].to_i).try(:initials)
      csv << ['', obj[:date], store_initials, obj[:department], obj[:job_id], obj[:job_rate], obj[:hours]]
    end
  end
end
