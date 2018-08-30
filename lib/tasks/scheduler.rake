desc "This task is called by the Heroku scheduler add-on"
task :perform_predictions => :environment do
  begin
    Prediction.perform_predictions
  rescue StandardError => ex
    Rails.logger.error "#{ex.message}"
    Rails.logger.error "#{ex.backtrace}"
    ex.backtrace.each { |line| Rails.logger.error line }
  end
end