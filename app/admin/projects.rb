ActiveAdmin.register Project do
  form partial: 'form'

  permit_params do
    fields = %i[full_name youtrack_token youtrack_url workflow_name]
    fields << :id if params[:action].in?(%w[create new])
    fields
  end

  filter :id
  filter :full_name
  filter :workflow_name
  filter :youtrack_url
  filter :youtrack_token
end
