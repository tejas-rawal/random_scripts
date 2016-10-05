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

LOGIN = 0

def set_track_vacation_flags
  core_db = ActiveRecord::Base.establish_connection(CORE_DB)
  query = "select login from managers where active = '1' and track_vacation = '1'"
  rows = core_db.connection.execute(query)
    
  rows.each do |row|
    user_profile = find_user_on_home(row[LOGIN])

    if user_profile
      user_profile.tap do |u|
        u.track_vacation = true
        u.save
      end
    end
  end
end

def find_user_on_home(username)
  ActiveRecord::Base.establish_connection("#{Rails.env}")
  User::Profile.where('username = ?', username.downcase).take
end

set_track_vacation_flags
