# RUN COMMAND
# BACKGROUND=y LOG_LEVEL=info INTERVAL=0.1 bundle exec rake predictions_task

task predictions_task: :environment do
  Rails.logger       = Logger.new(Rails.root.join('log', 'predictions_daemon.log'))
  Rails.logger.level = Logger.const_get((ENV['LOG_LEVEL'] || 'info').upcase)

  if ENV['BACKGROUND']
    Process.daemon(true, true)
  end

  # if ENV['PIDFILE']
  pid = ""
  begin
    File.open(File.join(Rails.root, 'tmp/pids/predictions_daemon.pid'), "r") do |f|
      f.each_line do |line|
        pid = line
      end
    end
    puts "KILLING PROCESS #{pid}"
    system("kill -9 #{pid}")
  rescue Exception => ex
    puts ex.backtrace
    puts "DAEMON NOT RUNNING"
  end

  File.open(File.join(Rails.root, 'tmp/pids/predictions_daemon.pid'), 'w') { |f| f << Process.pid }
  # end

  Signal.trap('TERM') { abort }
  # Rails.logger.info "Start daemon..."

  Rails.logger.info "RUNNING..."
  loop do
    # Daemon code goes here...
    begin
      Prediction.perform_predictions
    rescue StandardError => ex
      Rails.logger.error "#{ex.message}"
      Rails.logger.error "#{ex.backtrace}"
      ex.backtrace.each { |line| Rails.logger.error line }
    end
    sleep ENV['INTERVAL'].to_f || 1
  end
end