# Indices by column name
DEPARTMENT = 0
REVENUE_MIN = 1
LABOR_MIN = 2
LABOR_MAX = 3

# filepath = '/Users/tejasrawal/Documents/labor_ranges_formatted.csv'
filepath = '/data/home/shared/labor_ranges_formatted.csv'
data = CSV.read(filepath)

data[1..-1].each do |band|
  department = Store::Labor::Job::Department.where('name = ?', band[DEPARTMENT]).take
  
  if department
    Store::Labor::Planning::Range.new do |n|
      n.department_id = department.id
      n.revenue_minimum = band[REVENUE_MIN].to_i
      n.labor_hours_minimum = band[LABOR_MIN].to_f
      n.labor_hours_maximum = band[LABOR_MAX].to_f
      
      n.save
    end
  end
end