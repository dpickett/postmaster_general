require 'action_mailer'
require 'configatron'
require 'fileutils'

module PostmasterGeneral
  def self.log_directory=(path)
    configatron.postmaster_general.log_directory = path
  end

  def self.log_directory
    configatron.postmaster_general.log_directory
  end

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
