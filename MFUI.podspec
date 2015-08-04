Pod::Spec.new do |s|
  s.name         = "MFUI"
  s.version      = "1.5.0"
  s.summary      = "Movalys Framework MFUI."
  s.homepage     = "http://nansrvintc1.adeuza.fr/mfdocs-5.1.0/"
  s.license      = {
     :type => 'Commercial',
     :text => <<-LICENSE
          TODO
     LICENSE
  }
  s.author       = "Sopra Steria"
  s.requires_arc = true
  s.source       = { :git => "", :tag => "1.5.0" }
  s.platform     = :ios, '7.0'

  s.frameworks   = 'CoreLocation', 'MapKit', 'MessageUI', 'MagicalRecord', 'CocoaLumberjack', 'MFCore'
  s.header_mappings_dir = '.'
  s.source_files = 'MFUI/**/*.{h,m}'
  s.resources = 'MFUI/**/*.xib', "MFUI/resources/**/*.png", "MFUI/resources/**/*.plist", "MFUI/resources/**/*.txt",  "MFUI/resources/**/*.storyboard"

  s.prefix_header_contents = '#import "MFUIUtils.h"
    #import "UIView+ViewController.h"'

  s.subspec 'Dependencies' do|dep| 
    dep.dependency 'MBProgressHUD', '0.8'
    dep.dependency 'IQKeyboardManager', '3.2.3'
  end

  s.subspec 'NonARC' do |files|
    files.source_files = 'MFUI/**/MFPickerListSelectionIndicator.{h,m}'
    files.requires_arc = false
  end

  s.exclude_files = 'MFUI/**/MFPickerListSelectionIndicator.{h,m}'

end
