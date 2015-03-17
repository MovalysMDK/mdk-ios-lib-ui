Pod::Spec.new do |s|
  s.name         = "MFUI"
  s.version      = "1.3.0"
  s.summary      = "Movalys Framework MFUI."
  s.homepage     = "http://nansrvintc1.adeuza.fr/mfdocs-4.3.0/"
  s.license      = {
     :type => 'Commercial',
     :text => <<-LICENSE
          TODO
     LICENSE
  }
  s.author       = "Sopra Steria"
  s.requires_arc = true
  s.source       = { :git => "gitmovalys@git.ptx.fr.sopra:mfui.git", :tag => "1.3.0" }
  s.platform     = :ios, '6.0'
  s.dependency 'MBProgressHUD', '~>0.8'
  s.dependency 'ViewDeck', '~>2.2.11'
  s.frameworks   = 'CoreLocation', 'MapKit', 'MessageUI', 'MagicalRecord', 'MFCore'
  s.header_mappings_dir = '.'
  s.source_files = 'MFUI/**/*.{h,m}'
  s.resource_bundles = {
    'MFUIComponents' => ['MFUI/**/*.xib']  }

  s.subspec 'NonARC' do |files|
    files.source_files = 'MFUI/**/MFPickerListSelectionIndicator.{h,m}'
    files.requires_arc = false
  end

  s.exclude_files = 'MFUI/**/MFPickerListSelectionIndicator.{h,m}'

end
