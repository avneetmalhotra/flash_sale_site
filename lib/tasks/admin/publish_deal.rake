namespace :admin do
  
  desc "Publish today's deals at current time for 24 hours"
  task publish_deal: :environment do
    no_of_deals_published = Deal.publishable_on.update_all(start_at: Time.current, end_at: 1.day.after)
    puts "#{no_of_deals_published} deal published."
  end
end
