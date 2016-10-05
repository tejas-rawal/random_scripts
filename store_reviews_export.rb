# filepath = '/Users/tejasrawal/Desktop/dm_audits.csv'
filepath = '/data/home/shared/dm_store_reviews.csv'

CSV.open(filepath, 'wb') do |csv|
  csv << ['DM', 'Store', 'Standard Cleaning Checklist', 'FOH Cleanliness', 'Kitchen Cleanliness', 'Temp Logs Completion', 'Walk In Organization', 'Store Certification']
  Audit::StoreReview.where('draft = ?', false).order(:created_at).each do |review|
    csv << [review.user_profile.try(:full_name), review.store_location.try(:name), review.standard_cleaning_checklist_rating.to_i, review.foh_cleanliness_rating.to_i, review.kitchen_cleanliness_rating.to_i, review.temp_logs_completion_rating.to_i, review.walk_in_organization_rating.to_i, review.store_certification_rating.to_i]
  end
end