# -*- coding: utf-8 -*-
$:.unshift(ENV["RUBYMOTION_LIB"] || "/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
require 'sugarcube-attributedstring'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.

  config = YAML.load_file("config/#{app.build_mode}.yml")

  app.name = config['app']['name']
  app.identifier = config['app']['identifier']
  app.provisioning_profile = config['app']['provisioning_profile']

  if ENV['RUBYMOTION_LIB']
    app.motiondir = '../RubyMotion'
  end
  app.interface_orientations = [:portrait]
  app.deployment_target = '6.0'

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
  app.info_plist['config'] = config

  # facebook and url schemes
  facebook_app_id = config['facebook']['appId']
  app.info_plist['FacebookAppID'] = facebook_app_id
  app.info_plist['CFBundleURLTypes'] = [{
    'CFBundleURLName' => app.identifier,
    'CFBundleURLSchemes' => ["fb#{facebook_app_id}", "veoveo"]
  }]

end
