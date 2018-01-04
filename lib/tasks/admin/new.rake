namespace :admin do

  desc 'Create new admin'
  task new: :environment do
    admin_user = User.new
    admin_user.admin = true

    print "Enter admin's name: "
    admin_user.name = STDIN.gets.chomp

    print "Enter your Email address: "
    admin_user.email = STDIN.gets.chomp

    print "Enter your password: "
    admin_user.password = STDIN.noecho(&:gets).chomp

    print "\nPlease confirm your password: "
    admin_user.password_confirmation = STDIN.noecho(&:gets).chomp

    admin_user.confirmed_at = Time.current
    
    admin_user.save
      
    if admin_user.errors.any?
      puts "\n\n**Errors:**\n"
      admin_user.errors.full_messages.each { |full_message| puts full_message }
      puts "\nAdmin account not created. Please make your account again."
    else
      puts "\nAdmin successfully created."
    end
  end

end
