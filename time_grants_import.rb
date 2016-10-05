INSIDE_DB = {
    adapter: 'mysql2',
    host: 'localhost',
    database: 'inside_prod',
    username: 'root',
    password: 'EE1tISrHyb'
}

INSIDE_DB_DEV = {
  adapter: 'mysql2',
  host: 'localhost',
  database: 'inside_prod',
  username: 'root'
}

CORE_DB = {
  adapter: 'mysql2',
  host: 'localhost',
  database: 'core_prod',
  username: 'root',
  password: 'EE1tISrHyb'
}

CORE_DB_DEV = {
  adapter: 'mysql2',
  host: 'localhost',
  database: 'core_prod',
  username: 'root'
}

ID = 0
GRANT_TYPE = 1
AMOUNT = 2

LOGIN = 0

def fetch_manager_grants
  inside_db = ActiveRecord::Base.establish_connection(INSIDE_DB)
  query = "select manager_id, day_type, amount from time_grants"
  rows = inside_db.connection.execute(query)
  
  rows.each do |row|
    user_profile = find_manager_in_core(row[ID])
    
    if user_profile.present?
      grant_type_id = fetch_grant_type_id(row[GRANT_TYPE])
      amount_days = row[AMOUNT]

      VacationTracker::TimeGrant.create do |grant|
        grant.user_profile_id = user_profile.id
        grant.grant_type_id = grant_type_id
        grant.amount = amount_days
      end
    end
  end
end

def add_missing_grants
  ActiveRecord::Base.establish_connection("#{Rails.env}")
  
  User::Profile.includes(:vacation_time_grants).all.each do |user|
    VacationTracker::TimeGrantType.all.each do |type|
      unless user.vacation_time_grants.map(&:grant_type_id).include? type.id
        user.vacation_time_grants.where(grant_type_id: type.id).create({ amount: 0 })
      end
    end
  end
end

def find_manager_in_core(id)
  core_db = ActiveRecord::Base.establish_connection(CORE_DB)
  query = "select login from managers where id = '#{id}'"
  result = core_db.connection.execute(query)
  
  if result.first
    return find_user_on_home(result.first[LOGIN])
  end
end

def find_user_on_home(username)
  ActiveRecord::Base.establish_connection("#{Rails.env}")
  User::Profile.where('username = ?', username.downcase).take
end

def fetch_grant_type_id(grant)
  ActiveRecord::Base.establish_connection("#{Rails.env}")
  VacationTracker::TimeGrantType.find_by_name(grant.capitalize).try(:id)
end

fetch_manager_grants
# add_missing_grants