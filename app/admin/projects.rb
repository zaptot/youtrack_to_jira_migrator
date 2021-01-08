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
      row :created_at
      row :updated_at
    end

    panel 'Actions' do
      render partial: 'sync_actions'
    end
  end

  member_action :sync, method: :patch do
    resource.start_sync!

    Youtrack::Synchronizer.new(resource.id).sync
  end

  filter :id
  filter :full_name
  filter :workflow_name
  filter :youtrack_url
  filter :youtrack_token
end
