# -*- coding: utf-8 -*-
$:.unshift(ENV["RUBYMOTION_LIB"] || "/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
require 'sugarcube-attributedstring'
require 'bubble-wrap/location'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.

  # app.xcode_dir = "/Applications/Xcode.app/Contents/Developer"
  app.sdk_version = "6.1"
  app.deployment_target = '6.1'

  # load config file and put it in the info plist
  config = YAML.load_file("config/#{app.build_mode}.yml")
  app.info_plist['config'] = config

  app.name = config['app']['name']
  app.identifier = config['app']['identifier']
  app.provisioning_profile = config['app']['provisioning_profile']
  app.entitlements['aps-environment'] = config['app']['aps-environment']
  app.entitlements['get-task-allow'] = config['app']['get-task-allow']
  app.codesign_certificate = config['app']['codesign_certificate']

  app.version = "7"
  app.short_version = "1.0.0"

  if ENV['RUBYMOTION_LIB']
    app.motiondir = '../RubyMotion'
  end
  app.interface_orientations = [:portrait]

  app.frameworks += %w[
    CoreLocation
    MapKit
  ]

  app.pods do
    pod 'Facebook-iOS-SDK'
    pod 'MBProgressHUD'
    pod 'GGFullscreenImageViewController'
    pod 'TestFlightSDK'
  end

  # icons
  app.icons = ["App_Icon.png", "App_Icon@2x.png"]
  app.prerendered_icon = true

  # status bar
  app.info_plist['UIStatusBarStyle'] = 'UIStatusBarStyleBlackOpaque'

  # we require location services n stuff
  app.info_plist['UIRequiredDeviceCapabilities'] = ['location-services', 'gps']

  # facebook and url schemes
  facebook_app_id = config['facebook']['appId']
  app.info_plist['FacebookAppID'] = facebook_app_id
  app.info_plist['CFBundleURLTypes'] = [{
    'CFBundleURLName' => app.identifier,
    'CFBundleURLSchemes' => ["fb#{facebook_app_id}", "veoveo"]
  }]

end

desc "Release Testflight Build"
task :testflight => [
  :"archive:distribution"
] do

  build_path = './build/iPhoneOS-6.1-Release'
  ipa_path = "#{build_path}/VeoVeo.ipa"
  dsym_path = "#{build_path}/VeoVeo.dSYM"
  zipped_dsym_path = "#{build_path}/VeoVeo.dSYM.zip"

  # this should overwrite
  sh "zip -r #{zipped_dsym_path} #{dsym_path}"

  api_token = "c4e22ac831b1b976994bb7594d40902b_MTAxMjgy"
  team_token = "59240848237026c0556eca2582cf8110_MjQ1NDQ2MjAxMy0wNy0wNyAxOToyNDozNC42NDgwNjU"
  notes = "Latest Testflight Build"
  distribution_lists = "VeoVeo"
  sh "curl http://testflightapp.com/api/builds.json -F file=@#{ipa_path} -F dsym=@#{zipped_dsym_path} -F api_token=#{api_token} -F team_token=#{team_token} -F notes='#{notes}' -F distribution_lists=#{distribution_lists}"
end
