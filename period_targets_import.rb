require 'csv'
require 'date'

# based on column location in targets file
STORE = 0
DEPARTMENT = 2
TARGET = 3

filepath = '/Users/tejasrawal/Documents/10th_period_targets.csv'
# filepath = '/data/home/shared/10th_period_targets.csv'
targets = CSV.read(filepath)

def find_store_id(name)
  store = Store::Location.where('name = ?', name.downcase.strip)
  store.first.id if store.present?
end

def set_target_period
  period = Store::Labor::Period.where('period = ? and year = ?', 10, 2016) # Period and year according to file
  period.first.id if period.present?
end

def find_department_id(dept)
  department = Store::Labor::Job::Department.where('name = ?', dept)
  department.first.id if department.present?
end


targets[1..-1].each do |record|

  store_id = find_store_id(record[STORE])
  period = set_target_period
  department = find_department_id(record[DEPARTMENT])
    
  Store::Labor::Projection::HoursPerThousand.where(store_location_id: store_id, period_id: period, department_id: department).first_or_create.tap do |u|
    u.target = record[TARGET].present? ? record[TARGET].to_f : 0.0
    u.save
  end
end