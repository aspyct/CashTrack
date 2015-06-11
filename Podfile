pod 'CocoaLumberjack'
pod 'FMDB/standalone'
pod 'XYPieChart'

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
