# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

pod 'MFCore', '2.2.0-RC2'
pod 'MDKControl', '1.2.0-RC2'

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_STRICT_OBJC_MSGSEND'] = 'NO'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
  end
end
