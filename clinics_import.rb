require 'csv'

STORE_INITIALS = 0
CLINIC_NAME = 1
STREET_ADDRESS = 2
SUITE = 3
CITY = 4
STATE = 5
ZIP = 6
PHONE_NUMBER = 7
EXT = 8
FAX = 9
WEEKDAY_OPEN = 10
WEEKDAY_CLOSE = 11
WEEKEND_OPEN = 12
WEEKEND_CLOSE = 13
NOTES = 15

WEEKDAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday']
WEEKEND = ['saturday', 'sunday']

def find_store_id(initials)
  store = Store::Location.find_by_initials(initials)
  store.id if store
end

def add_open_hours(clinic, open_obj, weekday_open_t, weekend_open_t)
  if weekday_open_t
    weekday_open = weekday_open_t == '24/7' ? '12:00 AM' : weekday_open_t
    
    WEEKDAYS.each do |day|
      open_obj["#{day}_open_time"] = weekday_open
    end
  end
  
  if weekend_open_t
    weekend_open = weekend_open_t == '24/7' ? '12:00 AM' : weekend_open_t
    
    WEEKEND.each do |day|
      open_obj["#{day}_open_time"] = weekend_open
    end
  end
  
  open_obj
end

def add_close_hours(clinic, close_obj, weekday_close_t, weekend_close_t)
  if weekday_close_t
    weekday_close = weekday_close_t == '24/7' ? '11:59 PM' : weekday_close_t
    
    WEEKDAYS.each do |day|
      close_obj["#{day}_close_time"] = weekday_close
    end
  end
  
  if weekend_close_t
    weekend_close = weekend_close_t == '24/7' ? '11:59 PM' : weekend_close_t
    
    WEEKEND.each do |day|
      close_obj["#{day}_close_time"] = weekend_close
    end
  end
  
  close_obj
end
  
# filepath = '/Users/tejasrawal/Documents/store_clinics.csv'
filepath = '/data/home/shared/store_clinics.csv'
clinics = CSV.read(filepath)

clinics[1..-1].each do |clinic|
  open_time = {}
  close_time = {}
  store_id = find_store_id(clinic[STORE_INITIALS])
  fax = clinic[FAX].present? ? clinic[FAX].gsub(/\D/, '') : ''

  if store_id.present?
    new_clinic = Hr::MedicalClinic.new({store_location_id: store_id, name: clinic[CLINIC_NAME].strip})
    new_clinic.fax_number = clinic[FAX].gsub(/\D/, '') if clinic[FAX].present?
    new_clinic.notes = clinic[NOTES].strip if clinic[NOTES].present?
    open_time = add_open_hours(new_clinic, open_time, clinic[WEEKDAY_OPEN], clinic[WEEKEND_OPEN])
    close_time = add_close_hours(new_clinic, close_time, clinic[WEEKDAY_CLOSE], clinic[WEEKEND_CLOSE])
    
    new_clinic[:open_time] = open_time
    new_clinic[:close_time] = close_time

    new_clinic.add_phone({telephone_number: clinic[PHONE_NUMBER].gsub(/\D/, ''), extension: clinic[EXT].to_s}) if clinic[PHONE_NUMBER].present?
    new_clinic.add_address({street_address: clinic[STREET_ADDRESS], apt_suite: clinic[SUITE].to_s, city: clinic[CITY], state: clinic[STATE], zip_code: clinic[ZIP]})
    
    new_clinic.save!
  end
end
  