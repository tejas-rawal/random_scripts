def job_pos_code(job_id)
    case job_id.to_i
      when 11, 12
        1
      when 51
        8
      when 52
        9
      when 53
        10
      when 54
        11
      when 31, 32
        3
      when 33
        4
      when 76
        13
      when 71, 72, 75
        12
      when 73
        15
      when 74
        14
      when 81, 82, 83, 41, 42
        2
      when 91, 92, 93, 94, 95, 96
        5
      when 97, 98
        6
      else
        7
    end
  end

  def hs_job_id(job_code)
    case job_code
      when 1
        '988607973'
      when 2
        '988607974'
      when 3
        '988607985'
      when 4
        '988607984'
      when 5
        '988607989'
      when 6
        '988607990'
      when 7
        '988607991'
      when 8
        '988607993'
      when 9
        '988607986'
      when 10
        '988607983'
      when 11
        '988607988'
      when 12
        '988607995'
      when 13
        '988607992'
      when 14
        '988607997'
      when 15
        '988607994'
      else
        'No related HS Job Id for employee'
    end
  end


ExternalData::AssalEnterprise::Employee.where("emp_id is not null and emp_terminate is null and emp_storeid = ?", 1).each do |emp|
  HsJobRecord.create! do |record|
    record.store_id = 1
    record.emp_pos_id = emp.emp_pos_id
    record.job_id = emp.job_code.nil? ? 'nil' : emp.job_code
    record.job_pos_id = job_pos_code(emp.job_code)
    record.wage = emp.job_rate.to_f
    record.save
  end
end


HsJobRecord.where("store_id = ?", 1).each do |rec|
  rec.hs_job_id = hs_job_id(rec.job_pos_id)
  rec.save
end
