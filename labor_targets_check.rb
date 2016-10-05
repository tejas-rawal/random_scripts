period = 13 #Period 10, 2016

store_departments = Hash.new { |h, k| h[k] = {} }
Store::Location.not_departments.where('store_number > 0').each { |store| store_departments[store.name] }

store_departments.each do |k, v|
  store = Store::Location.find_by_name(k)
  hsh = {}
  
  Store::Labor::Job::Department.location_departments(store).each do |dept|
    dept_id = Store::Labor::Job::Department.find_by_name(dept).try(:id)
    flag = Store::Labor::Projection::HoursPerThousand.where(store_location_id: store.id, period_id: period, department_id: dept_id).first.present?
    hsh[dept] = flag
  end
    
  store_departments[k] = hsh
end