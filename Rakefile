# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'VeoVeo'
  app.identifier = 'com.tfm.veoveo'
  app.interface_orientations = [:portrait]

  app.frameworks += %w[
    CoreLocation
    MapKit
  ]

  app.pods do
    pod 'Facebook-iOS-SDK'
    pod 'PonyDebugger'
    pod 'SVProgressHUD'
    pod 'SDWebImage'
  end

  # icons
  app.icons = ["App_Icon.png", "App_Icon@2x.png"]
  app.prerendered_icon = true
  app.info_plist['UIStatusBarStyle'] = 'UIStatusBarStyleBlackOpaque'

  # need to figure out how to switch config
  config = YAML.load_file("config/development.yml")
  app.info_plist['AppConfig'] = config

  config = app.info_plist['AppConfig']
  facebook_app_id = config['facebook']['appId']
  app.info_plist['FacebookAppID'] = facebook_app_id
  app.info_plist['CFBundleURLTypes'] = [{
    'CFBundleURLSchemes' => ["fb#{facebook_app_id}", "veoveo"]
  }]

end
