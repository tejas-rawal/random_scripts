START_D = Date.new(2016, 02, 8) # Shortened week start date
END_D = Date.new(2016, 02, 21) # shortened week end date
ASSAL_CLOCK = ExternalData::AssalEnterprise::Clock
CLOCK_KEYS = ASSAL_CLOCK::CLOCK_KEYS

def retrieve_clock_hours(start_date, record_date, hours_hash)
  accumulated_hours = Hash.new

  ASSAL_CLOCK.where("#{CLOCK_KEYS[:date]} = ?", record_date).order("#{CLOCK_KEYS[:clock_in]}").each do |clk_record|
    employee_id = clk_record[CLOCK_KEYS[:payroll_id]]
    accumulated_hours[employee_id] ||= start_date == record_date ? 0.0 : sum_hours(employee_id, start_date, record_date - 1.day).to_f

    accumulated_hours[employee_id] += clk_record[CLOCK_KEYS[:hours]].to_f
    if accumulated_hours[employee_id] <= 40.0
      # if hours_hash[employee_id]
        hours_hash[employee_id] << format_clock_record(clk_record[CLOCK_KEYS[:payroll_id]], record_date.iso8601, clk_record[CLOCK_KEYS[:store_id]], clk_record[CLOCK_KEYS[:dept_id]], clk_record[CLOCK_KEYS[:job_id]], clk_record[CLOCK_KEYS[:rate]], clk_record[CLOCK_KEYS[:hours]], 0.0)
    else
      # accumulated_hours[employee_id] += clk_record[CLOCK_KEYS[:hours]].to_f
      if hours_hash[employee_id].map { |obj| obj[:ovt_hours] }.compact.reduce(:+) == 0.0
        hours_hash[employee_id] << format_clock_record(clk_record[CLOCK_KEYS[:payroll_id]], record_date.iso8601, clk_record[CLOCK_KEYS[:store_id]], clk_record[CLOCK_KEYS[:dept_id]], clk_record[CLOCK_KEYS[:job_id]], clk_record[CLOCK_KEYS[:rate]], 0.0, (accumulated_hours[employee_id] - 40.0).to_f)
      else
        hours_hash[employee_id] << format_clock_record(clk_record[CLOCK_KEYS[:payroll_id]], record_date.iso8601, clk_record[CLOCK_KEYS[:store_id]], clk_record[CLOCK_KEYS[:dept_id]], clk_record[CLOCK_KEYS[:job_id]], clk_record[CLOCK_KEYS[:rate]], 0.0, clk_record[CLOCK_KEYS[:hours]])
      end
    end
  end
  hours_hash
end

def group_hours_by_job(records_hash)
  records_hash.each do |emp_id, records_arr|
    records_hash[emp_id] = records_arr.group_by { |obj| obj[:job_id] }
  end

  records_hash
end

def sum_hours(emp_id, start_date, end_date)
  ASSAL_CLOCK.for_date_range(start_date, end_date).where("#{CLOCK_KEYS[:payroll_id]} = ?", emp_id).sum("#{CLOCK_KEYS[:hours]}")
end

def format_clock_record(employee_id, clk_date, store_number, dept, job_id, rate, reg_hours, ovt_hours)
  {
    corp_id: employee_id,
    date: clk_date,
    store: store_number,
    department: dept,
    job_id: job_id,
    job_rate: rate,
    reg_hours: reg_hours,
    ovt_hours: ovt_hours
  }
end

shortened_week_hours = Hash.new { |h, k| h[k] = [] }

(START_D..END_D).each do |date|
  retrieve_clock_hours(START_D, date, shortened_week_hours)
end

# group_hours_by_job(shortened_week_hours)
binding.pry
