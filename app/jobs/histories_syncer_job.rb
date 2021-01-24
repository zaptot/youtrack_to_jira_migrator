class HistoriesSyncerJob
  include SuckerPunch::Job

  def perform(project_id)
    Youtrack::Synchronizer.new(project_id).sync_histories
  end
end
