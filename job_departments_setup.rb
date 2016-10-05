departments_setup = {
  kitchen: {name: 'Kitchen', job_types: ['Kitchen', 'Kitchen Supervisor']},
  delivery: {name: 'Delivery', job_types: ['Driver', 'Dispatcher']},
  waitstaff: {name: 'Waitstaff', job_types: ['Waitstaff', 'Waitstaff Trainer', 'Party Room Waitstaff', 'Runner']},
  phc: {name: 'PHC', job_types: ['Phones', 'Host', 'Cashier', 'Key FOH']},
  bus: {name: 'Bus', job_types: ['Bus']},
  bar: {name: 'Bar', job_types: ['Bar']}
}

departments_setup.each do |key, value|
  Store::Labor::Job::Department.new.tap do |u|
    u.name = value[:name]
    value[:job_types].each do |type|
      u.job_types << Store::Labor::Job::Type.find_by_name(type)
    end
    u.save
  end
end

