platform :ios, '13.0'

target 'BirthdayReminder' do
  use_frameworks!

  # Pods for BirthdayReminder
  pod 'FSCalendar'
  
  # Firebase Authentication
  pod 'Firebase/Auth'
  pod 'GoogleSignIn'

  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
      end
    end
  end

  target 'BirthdayReminderTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BirthdayReminderUITests' do
    # Pods for testing
  end
end
