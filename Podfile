# Uncomment this line to define a global platform for your project
platform :ios, '7.0'

source 'gitmovalys@git.ptx.fr.sopra:podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!

pod 'MFCore', :path => '../mfcore'
pod 'MBProgressHUD', '0.8'

post_install do |installer_representation|
  installer_representation.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_STRICT_OBJC_MSGSEND'] = 'NO'
    end
  end
end
