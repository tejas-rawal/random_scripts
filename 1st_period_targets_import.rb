require 'csv'
require 'date'

STORE = 0
PERIOD = 1
DEPARTMENT = 2
TARGET = 3

# filepath = '/Users/tejasrawal/Desktop/1st_period_targets.csv'
filepath = '/data/home/shared/1st_period_targets.csv'
targets = CSV.read(filepath)

def find_store_id(name)
  store = Store::Location.where('name = ?', name.downcase.strip)
  store.first.id if store.present?
end

def set_target_period
  period = Store::Labor::Period.where('period = ? and year = ?', 1, 2016)
  period.first.id if period.present?
end

def find_department_id(dept)
  department = Store::Labor::Job::Department.where('name = ?', dept)
  department.first.id if department.present?
end


targets[1..-1].each do |record|
  # if record[TARGET].present?
    store_id = find_store_id(record[STORE])
    period = set_target_period
    department = find_department_id(record[DEPARTMENT])
    
    Store::Labor::Projection::HoursPerThousand.where(store_location_id: store_id, period_id: period, department_id: department).first_or_create do |u|
      # u.store_location_id = find_store_id(record[STORE])
      # u.period_id = set_target_period
      # u.department_id = find_department_id(record[DEPARTMENT])
      u.target = record[TARGET].present? ? record[TARGET].to_f : 0.0
      
      u.save
    end
  # end
end