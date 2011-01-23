require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "PostmasterGeneral" do
  context "configuration" do
    it "allows the setting of a log directory" do
      path = "/some/path"
      PostmasterGeneral.log_directory = path
      PostmasterGeneral.log_directory.should eql(path)
    end
  end

  context "logging" do
    TEST_LOG_PATH = File.join(File.dirname(__FILE__), "..", "tmp")

    let(:log_file_name) { "log.txt" }
    class SillyMailer < ActionMailer::Base
      def logging_is_for_kids
        mail(:to => "user@example.com", :from => "author@example.com") do |format|
          format.text { render :text => "Message" }
        end
      end
    end
    
    before do
      PostmasterGeneral.log_directory = TEST_LOG_PATH
    end

    after do
      FileUtils.rm_rf(TEST_LOG_PATH)
    end 

    it "creates a log file" do
      perform_delivery

      File.should exist(TEST_LOG_PATH + "/#{log_file_name}")
    end

    it "fills the log file in with the mail's encoded value" do
      mail = perform_delivery

      File.read(TEST_LOG_PATH + "/#{log_file_name}").should =~ /#{Regexp.escape(mail.encoded)}/
    end
  end

  def perform_delivery
    mail = nil

    PostmasterGeneral.log_deliveries(log_file_name) do
      mail = SillyMailer.logging_is_for_kids.deliver
    end

    mail
  end
end
