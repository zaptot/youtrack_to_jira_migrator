class WorklogsSyncerJob
  include SuckerPunch::Job
  workers 1

  def perform(project_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Youtrack::Synchronizer.new(project_id).sync_worklogs
    end
  end
end
