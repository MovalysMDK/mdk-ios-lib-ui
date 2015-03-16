# Uncomment this line to define a global platform for your project
platform :ios, '6.1'

source 'gitmovalys@git.ptx.fr.sopra:podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

target 'MFUI' do
	pod 'MFCore', :path => '../mfcore'
	pod 'ViewDeck', '~>2.2.11'
	pod 'MBProgressHUD', '~> 0.8'
end

target 'MFUITests' do
end

post_install do |installer_representation|
  installer_representation.project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_STRICT_OBJC_MSGSEND'] = 'NO'
    end
  end
end
