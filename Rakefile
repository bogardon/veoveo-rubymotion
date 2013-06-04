# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'rubygems'
require 'motion-cocoapods'
require 'bubble-wrap'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'VeoVeo'
  app.identifier = 'com.tfm.veoveo'
  app.interface_orientations = [:portrait]

  app.pods do
    pod 'Facebook-iOS-SDK'
    pod 'PonyDebugger'
  end

  # need to figure out how to switch config
  config = YAML.load_file("config/development.yml")
  facebook_app_id = config['facebook']['appId']
  app.info_plist['FacebookAppID'] = facebook_app_id
  app.info_plist['CFBundleURLTypes'] = [{
    'CFBundleURLSchemes' => ["fb#{facebook_app_id}", "veoveo"]
  }]

end
