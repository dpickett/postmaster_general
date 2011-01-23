require 'action_mailer'
require 'configatron'
require 'fileutils'

module PostmasterGeneral
  #sets the log directory for actionmailer logging
  def self.log_directory=(path)
    configatron.postmaster_general.log_directory = path
  end

  #returns the log directory configured previously
  def self.log_directory
    configatron.postmaster_general.log_directory
  end

  #logs mail deliveries performed within the specified block to the specified path
  #the path is appended to the previously configured log_directory
  def self.log_deliveries(path, &block)
    before_index = ActionMailer::Base.deliveries.size - 1
    before_index = 0 if before_index < 0

    yield

    log_path = File.join(log_directory, path)

    FileUtils.mkdir_p(File.dirname(log_path))
    FileUtils.rm_f(log_path)

    ActionMailer::Base.deliveries[before_index..-1].each do |mail|
      File.open(log_path, "w+") do |f|
        f << "=================="
        f << mail.encoded
        f << "=================="
      end
    end
  end
end
