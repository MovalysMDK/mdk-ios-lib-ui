#
#  Be sure to run `pod spec lint MDKControl.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "MFUI"
  spec.version      = "2.2.0-RC2"
  spec.summary      = "Movalys Framework MFUI."
  spec.homepage     = "http://www.movalys.org"
  spec.license      = { :type => 'LGPLv3', :file => 'LGPLv3-LICENSE.txt' }
  spec.author       = "Sopra Steria Group"
  spec.requires_arc = true
  spec.source       = { :git => "https://github.com/MovalysMDK/mdk-ios-lib-ui.git", :tag => "2.2.0-RC2" }
  spec.platform     = :ios, "8.0"

  spec.frameworks           = 'CoreLocation', 'MapKit', 'MessageUI', 'MagicalRecord', 'CocoaLumberjack', 'MFCore', 'MBProgressHUD', 'MDKControl'
  spec.header_mappings_dir  = '.'
  spec.source_files         = 'MFUI/**/*.{h,m}'
  spec.resources            = 'MFUI/**/*.xib', "MFUI/resources/**/*.png", "MFUI/resources/**/*.plist", "MFUI/resources/**/*.txt",  "MFUI/resources/**/*.storyboard"
  spec.prefix_header_contents = '#import "MFUIUtils.h"
                                 #import "UIView+ViewController.h"'

  spec.subspec 'NonARC' do |files|
    files.source_files = 'MFUI/**/MFPickerListSelectionIndicator.{h,m}'
    files.requires_arc = false
  end

  spec.exclude_files = 'MFUI/**/MFPickerListSelectionIndicator.{h,m}'

end
