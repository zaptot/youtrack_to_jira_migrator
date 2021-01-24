ActiveAdmin.register Project do
  form partial: 'form'

  permit_params do
    fields = %i[full_name youtrack_token youtrack_url workflow_name]
    fields << :id if params[:action].in?(%w[create new])
    fields
  end

  index do
    column :id
    column :full_name
    column :youtrack_url
    column :state

    actions
  end

  show do
    attributes_table do
      row :id
      row :full_name
      row :youtrack_url
      row :youtrack_token
      row :state
      row :workflow_name
      row :needed_states_in_workflow do
        controller.all_available_statuses
      end
      row :created_at
      row :updated_at
    end

    panel 'Actions' do
      render partial: 'sync_actions'
    end
  end

  controller do
    def all_available_statuses
      states = resource.issues.system_field_values('State')
      states += IssueHistory.for_project(resource.id)
                            .where(field_name: 'status')
                            .pluck(:from_string, :to_string)
                            .flatten
                            .uniq
      states.uniq.reject(&:blank?).map { |state| SyntaxMigrator.normalized_history_values('status', state) }
    end
  end

  member_action :sync_issues, method: :post do
    resource.start_sync_issues!

    IssueSyncerJob.perform_async(resource.id)

    redirect_to resource_path(resource)
  end

  member_action :sync_worklogs, method: :post do
    resource.start_sync_worklogs!

    WorklogsSyncerJob.perform_async(resource.id)

    redirect_to resource_path(resource)
  end

  member_action :sync_histories, method: :post do
    resource.start_sync_histories!

    HistoriesSyncerJob.perform_async(resource.id)

    redirect_to resource_path(resource)
  end

  member_action :download_import, method: :get do
    file = Jira::ImportGenerator.generate(resource.id)

    send_file file, type: 'application/json'
  end

  filter :id
  filter :full_name
  filter :workflow_name
  filter :youtrack_url
  filter :youtrack_token
end
