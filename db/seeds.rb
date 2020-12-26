SIZE_OF_SEED = 5

%w[TD LIVE].each do |project_id|
  Project.where(id: project_id, full_name: project_id, youtrack_token: 'y_token', youtrack_url: 'y_url').first_or_create!
end

Project.find_each do |project|
  SIZE_OF_SEED.times do |i|
    JiraUser.where(email: "user##{i}", project: project).first_or_create!
  end

  SIZE_OF_SEED.times do |i|
    Issue.where(title: "issue##{i}",
                number_in_project: -i,
                description: 'description',
                custom_fields: { fields: [{ value: 'c_value', type: 'select', name: 'c_name' }] },
                jira_user: project.jira_users[(rand * SIZE_OF_SEED).to_i],
                project: project).first_or_create!
  end
end

Issue.find_each do |issue|
  SIZE_OF_SEED.times do |i|
    Comment.where(body: "body#{i}",
                  jira_user: issue.project.jira_users[(rand * SIZE_OF_SEED).to_i],
                  issue: issue,
                  project_id: issue.project.id).first_or_create!
  end

  SIZE_OF_SEED.times do |i|
    Link.where(type: "type#{i}",
               issue_from: issue,
               issue_to: issue.project.issues[issue.id.next % SIZE_OF_SEED],
               project_id: issue.project.id).first_or_create!
  end
end

Issue.find_each do |issue|
  SIZE_OF_SEED.times do |i|
    Attachment.where(issue: issue,
                     url: "attachment_url#{i}_#{issue.id}",
                     name: "attachment#{i}",
                     project_id: issue.project.id).first_or_create!
  end
end
