ActiveAdmin.register Project do
  form partial: 'form'

  permit_params do
    fields = %i[full_name youtrack_token youtrack_url workflow_name jira_url]
    fields << :id if params[:action].in?(%w[create new])
    fields
  end

  index do
    selectable_column
    column :id
    column :full_name
    column :youtrack_url
    column :state
    column :jira_url

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
      row :jira_url
      row :needed_states_in_workflow do
        controller.all_available_statuses
      end
      row :created_at
      row :updated_at
    end

    panel 'Actions' do
      render partial: 'sync_actions'
    end

    table_for(resource.delayed_imports.not_deleted) do
      column :id
      column :name
      column :state
      column :updated_at
      column :created_at
      column :actions do |delay|
        if delay.finished?
          link_to :download, download_import_admin_project_path(delay_id: delay.id, resource_id: resource.id)
        end
      end
    end
  end

  filter :id
  filter :full_name
  filter :workflow_name
  filter :youtrack_url
  filter :youtrack_token

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

  member_action :generate_import, method: :post do
    Jira::ImportGenerateDelayer.new(resource).enqueue

    redirect_back(notice: 'Import delayed!', fallback_location: resource_path)
  end

  member_action :download_import, method: :get do
    delay = DelayedImport.find_by(id: params[:delay_id])
    if File.exist?(Rails.root.join(delay.file_path))
      send_file delay.file_path, type: 'application/json'
    else
      delay.mark_as_deleted! unless delay.deleted?
      redirect_back(notice: 'File not found!', fallback_location: resource_path(params[:id]))
    end
  end

  member_action :reset_project, method: :post do
    resource.start_reset_project!
    dependencies = Project.reflect_on_all_associations(:has_many)
    dependencies.each do |dependence|
      name = dependence.name
      resource.send(name).destroy_all
    end
    resource.reset_project!
    redirect_to resource_path(resource)
  rescue => e
    resource.fail!
    raise e
  end
end
