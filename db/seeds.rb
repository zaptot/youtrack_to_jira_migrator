SIZE_OF_SEED = 5

%w[TD LIVE].each do |project_id|
  Project.where(id: project_id, full_name: project_id, youtrack_token: 'y_token', youtrack_url: 'y_url').first_or_create
end

Project.find_each do |project|
  SIZE_OF_SEED.times do |i|
    JiraUser.where(email: "user##{i}", project_id: project.id).first_or_create
  end

  SIZE_OF_SEED.times do |i|
    Issue.where(title: "issue##{i}",
                number_in_project: -i,
                description: 'description',
                custom_fields: { fields: [{ value: 'c_value', type: 'select', name: 'c_name' }] },
                jira_user_id: (rand * SIZE_OF_SEED).to_i,
                project_id: project.id).first_or_create
  end
end

Issue.find_each do |issue|
  SIZE_OF_SEED.times do |i|
    Comment.where(body: "body#{i}", jira_user_id: (rand * SIZE_OF_SEED).to_i, issue: issue).first_or_create
  end

  SIZE_OF_SEED.times do |i|
    Link.where(type: "type#{i}", issue_from: issue.id, issue_to: issue.id.next % SIZE_OF_SEED).first_or_create
  end

  SIZE_OF_SEED.times do |i|
    Attachment.where(reference_type: 'Issue',
                     reference_id: issue.id,
                     url: 'attach_url',
                     name: "attachment#{i}").first_or_create
  end
end

Comment.find_each do |comment|
  SIZE_OF_SEED.times do |i|
    Attachment.where(reference_type: 'Comment',
                      reference_id: comment.id,
                      url: 'comment_url',
                      name: "comment#{i}").first_or_create
  end
end
