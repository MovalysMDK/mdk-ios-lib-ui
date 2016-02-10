Pod::Spec.new do |s|
  s.name         = "MFUI"
  s.version      = "1.3.0"
  s.summary      = "Movalys Framework MFUI."
  s.homepage     = "http://nansrvintc1.adeuza.fr/mfdocs-4.0/"
  s.license      = {
     :type => 'Commercial',
     :text => <<-LICENSE
          TODO
     LICENSE
  }
  s.author       = "Sopra Group"

  s.source       = { :git => "gitmovalys@git.ptx.fr.sopra:mfui.git", :tag => "1.3.0" }
  s.platform     = :ios, '6.0'
  s.dependency 'MBProgressHUD', '~>0.8'
  s.dependency 'ViewDeck', '~>2.2.11'
  s.frameworks   = 'CoreLocation', 'MapKit', 'MessageUI', 'MagicalRecord', 'CocoaLumberjack', 'MFCore'
  s.header_mappings_dir = '.'


  s.subspec 'NonARC' do |files|
    files.source_files = 'MFUI/**/MFPickerListSelectionIndicator.{h,m}'
    files.requires_arc = false
  end

  s.subspec 'Form' do |files|
    files.subspec 'Extend' do |extend|
      extend.source_files = 'MFUI/form/extend'
      extend.requires_arc = true
    end
    files.subspec 'Validation' do |validation|
      validation.source_files = 'MFUI/form/validation'
      validation.requires_arc = true
    end
    files.subspec 'Search' do |search|
      search.source_files = 'MFUI/form/search'
      search.requires_arc = true
    end
    files.source_files = 'MFUI/form'
    files.requires_arc = true
  end

  s.subspec 'Action' do |files|
   files.subspec 'Save' do |save|
      save.source_files = 'MFUI/action/save'
      save.requires_arc = true
    end
    files.subspec 'Delete' do |delete|
      delete.source_files = 'MFUI/action/delete'
      delete.requires_arc = true
    end
    files.subspec 'Email' do |email|
      email.source_files = 'MFUI/action/email'
      email.requires_arc = true
    end
    files.subspec 'Update' do |update|
      update.source_files = 'MFUI/action/update'
      update.requires_arc = true
    end
    files.source_files = 'MFUI/action'
    files.requires_arc = true
  end

  s.subspec 'Application' do |files|
    files.source_files = 'MFUI/application'
    files.requires_arc = true
  end

  s.subspec 'Binding' do |files|
    files.source_files = 'MFUI/binding'
    files.requires_arc = true
  end

  s.subspec 'Cell' do |files|
    files.source_files = 'MFUI/cells'
    files.requires_arc = true
  end

  s.subspec 'Controls' do |files|
    files.subspec 'Label' do |label|
      label.source_files = 'MFUI/control/label'
      label.requires_arc = true
    end

    files.subspec 'List' do |list|
      list.source_files = 'MFUI/control/list'
      list.exclude_files = 'MFUI/**/MFPickerListSelectionIndicator.{h,m}'
      list.requires_arc = true
    end

    files.subspec 'Photo' do |photo|
      photo.source_files = 'MFUI/control/photo'
      photo.requires_arc = true
    end

    files.subspec 'Tooltip' do |tooltip|
      tooltip.source_files = 'MFUI/control/tooltip'
      tooltip.requires_arc = true
    end

    files.subspec 'Button' do |button|
      button.source_files = 'MFUI/control/button'
      button.requires_arc = true
    end

    files.subspec 'Image' do |image|
      image.source_files = 'MFUI/control/image'
      image.requires_arc = true
    end
    
    files.subspec 'WebView' do |webview|
      webview.source_files = 'MFUI/control/webview'
      webview.requires_arc = true
    end

    files.subspec 'Position' do |position|
      position.source_files = 'MFUI/control/position'
      position.requires_arc = true
    end

    files.subspec 'TextField' do |textfield|

      textfield.subspec 'Phone' do |phone|
        phone.source_files = 'MFUI/control/textfield/phone'
        phone.requires_arc = true
      end
      textfield.subspec 'Email' do |email|
        email.source_files = 'MFUI/control/textfield/email'
        email.requires_arc = true
      end
      textfield.subspec 'Number' do |number|
        number.source_files = 'MFUI/control/textfield/number'
        number.requires_arc = true
      end
      textfield.subspec 'Url' do |url|
        url.source_files = 'MFUI/control/textfield/url'
        url.requires_arc = true
      end

      textfield.source_files = 'MFUI/control/textfield'
      textfield.requires_arc = true
    end

    files.subspec 'Enum' do |enum|
      enum.source_files = 'MFUI/control/enum'
      enum.requires_arc = true
    end

    files.subspec 'Signature' do |signature|
      signature.source_files = 'MFUI/control/signature'
      signature.requires_arc = true
    end

    files.subspec 'Switch' do |switch|
      switch.source_files = 'MFUI/control/switch'
      switch.requires_arc = true
    end

    files.subspec 'Slider' do |slider|
      slider.source_files = 'MFUI/control/slider'
      slider.requires_arc = true
    end

    files.subspec 'Scanner' do |scanner|
      scanner.source_files = 'MFUI/control/scanner'
      scanner.requires_arc = true
    end

    files.subspec 'Number' do |number|
      number.source_files = 'MFUI/control/number'
      number.requires_arc = true
    end

    files.subspec 'Date' do |date|
      date.source_files = 'MFUI/control/date'
      date.requires_arc = true
    end

    files.source_files = 'MFUI/control'
    files.requires_arc = true
  end

  s.subspec 'ControlExtension' do |files|
    files.source_files = 'MFUI/controlExtension'
    files.requires_arc = true
  end

  s.subspec 'ViewController' do |files|
      files.subspec 'Container' do |container|
        container.subspec 'Workspace' do |workspace|
          workspace.source_files = 'MFUI/viewcontroller/container/workspace'
          workspace.requires_arc = true
        end
        container.subspec 'Multipanel' do |multipanel|
          multipanel.source_files = 'MFUI/viewcontroller/container/multipanel'
          multipanel.requires_arc = true
        end
        container.source_files = 'MFUI/viewcontroller/container'
        container.requires_arc = true
      end


      files.subspec 'Form' do |form|
        form.source_files = 'MFUI/viewcontroller/form'
        form.requires_arc = true
      end
      files.subspec 'Splash' do |splash|
        splash.source_files = 'MFUI/viewcontroller/splash'
        splash.requires_arc = true
      end
      files.subspec 'Menu' do |menu|
        menu.source_files = 'MFUI/viewcontroller/menu'
        menu.requires_arc = true
      end
      files.subspec 'Deck' do |deck|
        deck.source_files = 'MFUI/viewcontroller/deck'
        deck.requires_arc = true
      end
      files.subspec 'Detail' do |detail|
        detail.source_files = 'MFUI/viewcontroller/detail'
        detail.requires_arc = true
      end
      files.subspec 'Transition' do |transition|
        transition.source_files = 'MFUI/viewcontroller/transition'
        transition.requires_arc = true
      end

      files.subspec 'Photo' do |photo|
        photo.source_files = 'MFUI/viewcontroller/photo'
        photo.requires_arc = true
      end
      files.subspec 'Position' do |position|
        position.source_files = 'MFUI/viewcontroller/position'
        position.requires_arc = true
      end
      files.subspec 'Email' do |email|
        email.source_files = 'MFUI/viewcontroller/email'
        email.requires_arc = true
      end
      files.subspec 'Web' do |web|
        web.source_files = 'MFUI/viewcontroller/web'
        web.requires_arc = true
      end
    files.source_files = 'MFUI/viewcontroller'
    files.requires_arc = true
  end

  s.subspec 'Error' do |files|
    files.source_files = 'MFUI/error'
    files.requires_arc = true
  end

  s.subspec 'Utils' do |files|
    files.subspec 'TypeProcessing' do |processing|
      processing.source_files = 'MFUI/utils/processing'
      processing.requires_arc = false
    end
    files.subspec 'Helper' do |helper|
      helper.source_files = 'MFUI/utils/helper'
      helper.requires_arc = false
    end
    files.source_files = 'MFUI/utils'
    files.requires_arc = true
  end

  s.subspec 'Logging' do |files|
    files.source_files = 'MFUI/log'
    files.requires_arc = true
  end

  s.subspec 'Motion' do |files|
    files.source_files = 'MFUI/motion'
    files.requires_arc = true
  end

  s.subspec 'Converter' do |files|
    files.source_files = 'MFUI/conversion'
    files.requires_arc = true
  end

  s.subspec 'View' do |files|
    files.source_files = 'MFUI/view'
    files.requires_arc = true
  end

  s.subspec 'ViewModel' do |files|
    files.source_files = 'MFUI/viewmodel'
    files.requires_arc = true
  end

  s.subspec 'Protocols' do |files|
    files.source_files = 'MFUI/protocol'
    files.requires_arc = true
  end

  s.subspec 'test' do |files|
      files.source_files = 'MFUI/test'
      files.requires_arc = true
  end

  s.source_files = 'MFUI'
end
