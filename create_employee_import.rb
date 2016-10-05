#/bin/ruby
#needs ruby v 1.92+
#expects the input text file to be CSV with id,firstn,lastn,addr3,city,state,zip,email
#this only uses id,lastn,addr3 and zip in logic
#Created by Jake on 20013-4-18.
require 'Date'

#VALIDATE AFTERWARDS grep -vn "update cust set usercode4 \= \(['0-9]\+\) where id \= \(['0-9]\+\)\;" export_household_id.sql

infile = "test.csv"
input_file = File.open(infile,"r")
out_file = File.new("exmployee_export.rb",File::CREAT|File::TRUNC|File::RDWR, 0644)

cust_array = Array.new

class String
    def is_i?
       !!(self =~ /\A[-+]?[0-9]+\z/)
    end
end


KNOWN_ROLES = ['ADMIN', 'GENERAL MANAGER', 'REGIONAL MANAGER', 'DISTRICT MANAGER', 'KEY PERSON', 'REPAIR', 'DIRECTOR', 'KITCHEN SUPERVISOR']


ADMIN_ROLE = KNOWN_ROLES[0]
GM_ROLE = KNOWN_ROLES[1]
RM_ROLE = KNOWN_ROLES[2]
DM_ROLE = KNOWN_ROLES[3]
KEY_ROLE = KNOWN_ROLES[4]
REPAIR_ROLE = KNOWN_ROLES[5]
DIRECTOR_ROLE = KNOWN_ROLES[6]
KITCHEN_ROLE = KNOWN_ROLES[7]


STORE_NAME = 0
DEPARTMENT_NAME = 1
LOGIN = 2
RANK_NAME = 3
START_DATE = 4
END_DATE = 5
STORE_INITIALS = 6
STORE_OPENNED_DATE = 7
STORE_NUMBER = 8

LAST_LOGIN = '1971-03-17'

def convert_name(name_string)
  name_string.downcase.gsub(/[\-\/]/, ' ')
end

def convert_to_variable_name(name_string)
  converted_name = convert_name(name_string)  
  converted_name.gsub(/[\s]/, '_')
end

def prompt(*args)
    print(*args)
    gets
end

def assignment_name_lookup(ranks)
  
  case ranks
    
  when "DM"
    convert_to_variable_name(DM_ROLE)
  when "GM"
    convert_to_variable_name(GM_ROLE)
  when "Manager"
    convert_to_variable_name(GM_ROLE)
  when "2"
    convert_to_variable_name(GM_ROLE)
  when "3"
    convert_to_variable_name(GM_ROLE)
  when "4"
    convert_to_variable_name(GM_ROLE)
  when "RM"
    convert_to_variable_name(RM_ROLE)
  when "Key Person"
    convert_to_variable_name(KEY_ROLE)
  when "Kitchen Supervisor"
    convert_to_variable_name(KITCHEN_ROLE)
  when "Director"
    convert_to_variable_name(DIRECTOR_ROLE)
  else
    nil
  end
  
end

user_hash = {}

store_hash = {}

input_file.each_line{|line|
  
  user_assignments = []
  
  assignment_array = line.split(/\t/)
  
  current_user = assignment_array[LOGIN]
  
  next if current_user == 'login'
  
  if user_hash[current_user] == nil
    user_hash[current_user] = []
  end
  
  
  
  store_name = assignment_array[STORE_NAME]
  department_name = assignment_array[DEPARTMENT_NAME]
  
  next if convert_name(department_name) == 'stu' || convert_name(department_name) == 'kathy' || convert_name(department_name) == 'marc' || convert_name(department_name) == 'cfo'
  
  if store_name != 'NULL'
    if store_hash[store_name] == nil
      store_hash[store_name] = [convert_name(store_name), assignment_array[STORE_NUMBER], assignment_array[STORE_INITIALS], assignment_array[STORE_OPENNED_DATE]]
    end
  
    user_assignments = [assignment_array[STORE_NAME], assignment_array[RANK_NAME],assignment_array[START_DATE], assignment_array[END_DATE]]
  
  elsif assignment_array[DEPARTMENT_NAME] != 'NULL'
    if store_hash[department_name] == nil
      store_hash[department_name] = [convert_name(department_name), assignment_array[STORE_NUMBER], assignment_array[STORE_INITIALS], assignment_array[STORE_OPENNED_DATE]]
    end
    
    user_assignments = [assignment_array[DEPARTMENT_NAME], assignment_array[RANK_NAME],assignment_array[START_DATE], assignment_array[END_DATE]]
  
  end
  
  next if user_assignments.empty?
  
  user_hash[current_user] << user_assignments
  #clean the input of invalid characters
  
}
ARRAY_STORE_NAME = 0
ARRAY_STORE_NUMBER = 1
ARRAY_STORE_INITIALS = 2
ARRAY_STORE_OPEN_DATE = 3


USER_STORE_NAME = 0
USER_ROLE = 1
USER_START_DATE = 2
USER_END_DATE = 3

store_number = 0;


KNOWN_ROLES.each{|role|
  var_name = convert_to_variable_name(role)
  out_file << "#{var_name} = User::Role.where(role_name: '#{role}').first_or_create!\n"
}
out_file << "\n"

store_hash.each{|store_name, store_details|
  initials = store_details
  
  store_details[ARRAY_STORE_NUMBER].chomp!
  
  if store_details[ARRAY_STORE_NUMBER] == 'NULL'
    store_number = store_number - 1
    store_details[ARRAY_STORE_NUMBER] = "#{store_number}"
    
  end
  
  if store_details[ARRAY_STORE_OPEN_DATE] == 'NULL'
    store_details[ARRAY_STORE_OPEN_DATE] = '1971-03-17'
  end
  
  if store_details[ARRAY_STORE_INITIALS] == 'NULL'
    store_details[ARRAY_STORE_INITIALS] = (prompt "What are the initials for #{store_name}?").chomp.upcase
  end
    
  
  var_store_name = convert_to_variable_name(store_details[ARRAY_STORE_NAME])
  out_file << "#{var_store_name } = Store::Location.where(name: '#{store_details[ARRAY_STORE_NAME]}', store_number:'#{store_details[ARRAY_STORE_NUMBER]}').first_or_create!.tap do |u|\n"
  out_file << "  u.initials = '#{store_details[ARRAY_STORE_INITIALS].upcase}'\n"
  out_file << "  u.open_date = Date.parse('#{store_details[ARRAY_STORE_OPEN_DATE]}')\n"
  out_file << "  u.save \n"
  out_file << "end\n\n"
}

user_hash.each{ |user, user_assn|  
  converted_name = convert_name(user)
  user_var_name = convert_to_variable_name(user)
  next if user_assn == nil
  next if user_assn[0] == nil
  next if user == ''
  next if converted_name.is_i?
  
  out_file << "User::Profile.where(username:'#{converted_name}').first_or_create!.tap do |u|\n"
  out_file << "  u.last_login_at = Date.parse('1971-03-17')\n"
  user_assn.each{|current_assignment|
    next if current_assignment.empty?
    var_store_name = convert_to_variable_name(current_assignment[USER_STORE_NAME])
    
    out_file << "  u.user_store_records.create(location_id: #{var_store_name}.id, start_date: '#{current_assignment[USER_START_DATE]}', end_date: '#{current_assignment[USER_END_DATE]}')\n"
  
  }
  
  user_assn.each{|current_assignment|
    next if current_assignment.empty?

    var_role_name = assignment_name_lookup(current_assignment[USER_ROLE])

    if var_role_name != nil
      out_file << "  u.user_role_records.create(role_id: #{var_role_name}.id, start_date: '#{current_assignment[USER_START_DATE]}', end_date: '#{current_assignment[USER_END_DATE]}')\n"
    end
  
  }
  
  out_file << "  u.save\n"
  out_file << "end\n\n"
}