require 'csv'
require 'date'

# Indices
STORE_INITIALS = 2
DEPARTMENT = 4
PROJECTION = 44 # Period 10
ALLOWED = ['Dining Room', 'Carryout', 'Delivery']

filepath = '/Users/tejasrawal/Desktop/revenue_budget_increases.csv'
# filepath = '/data/home/shared/revenue_budget_increases.csv'
projections = CSV.read(filepath)
period_id = Store::Labor::Period.where('period = ? and year = ?', 10, 2016).first.id

def find_store_id(initials)
  store = Store::Location.where('initials = ?', initials.strip)
  store.first.try(:id) if store.present?
end

def format_revenue_factor(number)
  number.to_f - 100.0
end

projections[2..-23].each do |p|
  if ALLOWED.include? p[DEPARTMENT]
    store_id = find_store_id(p[STORE_INITIALS])
    figure = format_revenue_factor(p[PROJECTION])
    
    if store_id.present?
      Store::Labor::Projection::Revenue.where(store_location_id: store_id, period_id: period_id).first_or_create!.tap do |u|
        case p[DEPARTMENT]
        when 'Dining Room'
          u.dine_in_revenue = figure
        when 'Carryout'
          u.carryout_revenue = figure
        when 'Delivery'
          u.delivery_revenue = figure
        else
          nil  
        end
        u.save
      end
    end
  end
end

