require 'csv'
USER = 0

def initialize_supervisors
  ActiveRecord::Base.establish_connection("#{Rails.env}")
  User::Profile.where('track_vacation = ?', true).each do |user|
    VacationTracker::Supervisor.where(username: user.username).first_or_create do |supervisor|
      supervisor.supervisor_name = user.full_name if user.full_name.present?
    end
  end
end
  
def add_supervisors_records  
  # csv_file = '/Users/tejasrawal/Desktop/supervisors.csv'
  csv_file = '/data/home/shared/supervisors.csv'
  
  supervisor_records = CSV.read(csv_file)
  
  supervisor_records.each do |row|
    user_profile = find_user_on_home(row[USER])
    
    if user_profile
      row[1..-1].each do |supervisor|
        supervisor_record = find_vacation_supervisor(supervisor)
        user_profile.supervisor_manager_records.create(vacation_supervisor_id: supervisor_record.id) if supervisor_record.present?
      end
    end
  end
end

def delete_non_supervisors  
  VacationTracker::Supervisor.all.each do |supervisor|
    supervisor.destroy if supervisor.user_profiles.empty?
  end
end

def find_user_on_home(username)
  ActiveRecord::Base.establish_connection("#{Rails.env}")
  User::Profile.where('username = ?', username).take
end

def find_vacation_supervisor(username)
  ActiveRecord::Base.establish_connection("#{Rails.env}")
  VacationTracker::Supervisor.where('username = ?', username).take
end

initialize_supervisors
add_supervisors_records
delete_non_supervisors