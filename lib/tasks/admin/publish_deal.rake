namespace :admin do
  
  desc 'Publish deal now for 24 hours'
  task :publish_deal => :environment do
    Deal.deals_on_publishing_date.update_all(start_at: Time.current, end_at: Time.current + 24.hours)
  end
end
