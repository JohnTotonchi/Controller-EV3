# Uncomment this line to define a global platform for your project
# platform :ios, ’9.0’

target 'ControllerEV3' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'Socket.IO-Client-Swift', '~> 8.3.0' # Or latest version
  pod ‘CDJoystick’
  pod 'SwiftyJSON'

  # Pods for ControllerEV3

  target 'ControllerEV3Tests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ControllerEV3UITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end