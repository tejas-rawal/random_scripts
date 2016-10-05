require 'csv'
# filepath = '/data/home/shared/store_managers.csv'

# CSV.open(filepath, 'wb') do |csv|
#   csv << ['First Name', 'Last Name', 'Email', 'Store #', 'Rank']
#   Store::Location.where('store_number > 0').each do |store|
#     store.all_location_gms.each do |manager|
#       csv << [manager.first_name, manager.last_name, manager.email_address, store.store_number, manager.manager_rank]
#     end
#   end
# end
  
filepath = '/data/home/shared/store_district_managers.csv'

CSV.open(filepath, 'wb') do |csv|
  csv << ['First Name', 'Last Name', 'Email', 'Stores']
  User::Role.includes(:user_profiles).find_by_role_name('DISTRICT MANAGER').current_user_profiles.each do |manager|
    csv << [manager.first_name, manager.last_name, manager.email_address, manager.current_stores.map(&:initials).join(', ')]
  end
end