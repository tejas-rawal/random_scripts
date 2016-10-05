# run on core_prod
# rails console production then run file
require 'csv'
 
supervisors_hash = Manager.where('active = ? and track_vacation = ?', '1', '1').each_with_object({}) { |manager, hsh| hsh[manager.login] = manager.supervisors.map { |s| s.login } }

CSV.open('/u/apps/core/shared/supervisors.csv', 'wb') do |csv|
  supervisors_hash.each do |user, supervisors|
    csv << [user, supervisors].flatten
  end
end