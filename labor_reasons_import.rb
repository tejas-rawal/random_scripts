reasons = ['Slow Off Early', 'Late', 'Early', 'No Show', 'Ilness', 'Personal', 'Disciplined', 'Car Problems', 'Rate Diff./Inc.', 'Perm Shift Change', 'Busy Stay Late', 'In Early Prep', 'Extra - Cater', 'Extra - Holiday', 'Extra - Busy', 'Extra - Special Event', 'Rate Increase', 'Training', 'Discipline Cover', 'Manager Coverage', 'Key Open', 'Other Department']

reasons.each do |reason|
  Store::Labor::Job::Reason.new.tap do |u|
    u.reason = reason
    u.save
  end
end