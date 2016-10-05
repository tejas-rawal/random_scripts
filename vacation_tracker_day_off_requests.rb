INSIDE = {
  email: 0,
  request_type: 1,
  request_date: 2,
  # email: 2,
  manager_id: 3,
  covering_manager: 4,
  state: 5,
  approved_by: 6
}

CORE = {
  login: 0
}

def fetch_database(db_name)
  {
    adapter: 'mysql2',
    host: 'localhost',
    database: "#{db_name}",
    username: 'root',
    # password: 'EE1tISrHyb'

  }
end

def fetch_day_used_records
  inside_db = ActiveRecord::Base.establish_connection(fetch_database('inside_prod'))
  db_query = %Q{
    SELECT m.email, d.day_type, d.date_used, d.manager_id, d.covering_manager, d.state, d.approved_by FROM day_useds d
    LEFT JOIN managers m ON m.id = d.manager_id
    WHERE m.email is not null and m.active = '1' and d.date_used > '2016-03-31' and d.state not in ('deleted', 'delete_apr', 'delete_rej', 'delete_req', 'rejected')
    ORDER BY d.manager_id, d.date_used
  }
  # query = "select d.day_type, d.date_used, m.email, d.manager_id, d.covering_manager, d.state, d.approved_by from day_useds d LEFT JOIN managers m on m.id = d.manager_id where d.date_used > '2016-03-31' and d.state not in ('deleted', 'delete_apr', 'delete_rej', 'delete_req', 'rejected') order by d.manager_id, d.date_used"
  # rows = inside_db.connection.execute(query)
  rows = inside_db.connection.execute(db_query)
  binding.pry
  # .delete_if { |request| has_assignments?(request[INSIDE[:manager_id]]) }
  
  ranges = rows.inject([]) do |spans, n|
    # if requests are not for consecutive days by same person for same request type
    if spans.empty? || spans.last.last[INSIDE[:request_date]] != n[INSIDE[:request_date]] - 1 || n[INSIDE[:email]] != spans.last.last[INSIDE[:email]] || spans.last.last[INSIDE[:request_type]] != n[INSIDE[:request_type]]
      spans + [n..n]
    else
      spans[0..-2] + [spans.last.first..n]
    end
  end
  
  ranges.each do |range|
    end_date = nil
    profile = nil
    approved_id = nil
    status = range.begin[INSIDE[:state]].capitalize
    type = fetch_grant_type_id(range.begin[INSIDE[:request_type]])
    covering = range.begin[INSIDE[:covering_manager]]
    start_date = range.begin[INSIDE[:request_date]]

    if (start_date != range.end[INSIDE[:request_date]]) && (start_date < range.end[INSIDE[:request_date]])
      end_date = range.end[INSIDE[:request_date]]
    end
    
    if range.begin[INSIDE[:email]].present?
      profile = find_user_on_home(range.begin[INSIDE[:email]])
    else
      profile = find_manager_in_core(range.begin[INSIDE[:manager_id]])
    end
    
    if range.begin[INSIDE[:approved_by]]
      approved_id = find_manager_in_core(range.begin[INSIDE[:approved_by]])
    end
    
    if profile.present?
      create_vacation_request(build_request_attributes(type, start_date, end_date, profile, status, covering, approved_id))
    end
  end
end

def has_assignments?(id)
  core_db = ActiveRecord::Base.establish_connection(fetch_database('core_prod'))
  assignments_query = %Q{SELECT COUNT(id) from assignments where manager_id = '#{id}' and active = '1' and end_date is null}
  results = core_db.connection.execute(assignments_query)
  
  false if results.length > 0
end

def find_manager_in_core(id)
  core_db = ActiveRecord::Base.establish_connection(fetch_database('core_prod'))
  query = %Q{SELECT login from managers where id = '#{id}'}
  result = core_db.connection.execute(query)
  
  if result.first
    return find_user_on_home(result.take[CORE[:login]])
  end
end


def build_request_attributes(type, start_d, end_d, profile, status, covering, approved_id)
  {
    request_type_id: type,
    user_profile_id: profile,
    start_date: start_d,
    end_date: end_d,
    status: status,
    covering_manager: covering,
    approved_by_id: approved_id
  }
end

def create_vacation_request(attrs = {})
  ActiveRecord::Base.establish_connection("#{Rails.env}")
  VacationTracker::TimeOffRequest.skip_callback(:create, :before, :assign_status)
  VacationTracker::TimeOffRequest.skip_callback(:create, :after, :request_supervisor_approval)
  VacationTracker::TimeOffRequest.skip_callback(:update, :after, :check_if_approved)
  
  VacationTracker::TimeOffRequest.new(attrs).save(validate: false) 
end

def find_user_on_home(username)
  ActiveRecord::Base.establish_connection("#{Rails.env}")
  User::Profile.where('username = ?', username.downcase).take.try(:id)
end

def fetch_grant_type_id(grant)
  ActiveRecord::Base.establish_connection("#{Rails.env}")
  VacationTracker::TimeGrantType.find_by_name(grant.capitalize).try(:id)
end

fetch_day_used_records