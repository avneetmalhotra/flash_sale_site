class ApplicationMailer < ActionMailer::Base
  default from: ENV['senders_email_address']
  layout 'mailer'
end
