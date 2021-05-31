class DelayImportJob
  include SuckerPunch::Job
  workers 1

  def perform(delay_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Jira::ImportGenerator.generate(delay_id)
    end
  end
end
