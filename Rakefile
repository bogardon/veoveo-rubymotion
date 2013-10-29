# -*- coding: utf-8 -*-
$:.unshift(ENV["RUBYMOTION_LIB"] || "/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.

  app.sdk_version = "6.1"
  app.deployment_target = "6.1"

  # app.archs['iPhoneOS'] << 'arm64'
  # app.archs['iPhoneSimulator'] << 'x86_64'

  # load config file and put it in the info plist
  config = YAML.load_file("config/#{app.build_mode}.yml")
  app.info_plist['config'] = config

  app.name = config['app']['name']
  app.identifier = config['app']['identifier']
  app.provisioning_profile = config['app']['provisioning_profile']
  app.entitlements['aps-environment'] = config['app']['aps-environment']
  app.entitlements['get-task-allow'] = config['app']['get-task-allow']
  app.codesign_certificate = config['app']['codesign_certificate']

  app.short_version = app.version = "1.0.0"
  app.version = VERSION if VERSION

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
    pod 'TMCache'
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

def notify_hipchat(message)
  hipchat_room = "VeoVeo"
  hipchat_from = "TestFlight"
  hipchat_message = message
  hipchat_api_token = "ff4e32ffecd9efef18d7fdeab44c11"

  sh "curl -d \"room_id=#{hipchat_room}&from=#{hipchat_from}&message=#{hipchat_message}&color=green\"  https://api.hipchat.com/v1/rooms/message?auth_token=#{hipchat_api_token}&format=json"
end

task :set_and_bump_version do
  next_build_path = "./nextBuildNumber"
  VERSION = File.open(next_build_path).read.strip
  File.open(next_build_path, "w+") do |f|
    f.write "#{VERSION.to_i + 1}"
  end

  notify_hipchat("Preparing Build #{VERSION}!")
end

task :secret_clean do
  sh "rake clean"
end

desc "Release Testflight Build"
task :testflight => [
  :secret_clean,
  :set_and_bump_version,
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

  notify_hipchat("Uploaded Build #{VERSION}!")
end
