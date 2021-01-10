class WorklogsSyncerJob
  include SuckerPunch::Job
  workers 4

  def perform(project_id)
    Youtrack::Synchronizer.new(project_id).sync_worklogs
  end
end
