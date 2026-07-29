#!/usr/bin/env ruby
# frozen_string_literal: true

# Adds the Share and Widget extension targets to ios/Runner.xcodeproj.
#
# Written as a script rather than applied by hand because project.pbxproj is a
# graph of cross-referencing UUIDs: an edit that looks right in a diff can still
# produce a file Xcode refuses to open. Re-running it is safe — existing targets
# are removed and rebuilt, so it doubles as the way to regenerate them after a
# `flutter create` regenerates the project.
#
#   ruby scripts/add_ios_extensions.rb

require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
PROJECT = File.join(ROOT, 'ios', 'Runner.xcodeproj')
APP_BUNDLE_ID = 'com.kvlkstudio.plokee'
TEAM = '3SQ7Y32MZN'

EXTENSIONS = [
  {
    name: 'PlokeeShare',
    bundle_suffix: 'Share',
    deployment: '13.0',
    sources: ['PlokeeShare/ShareViewController.swift'],
    info_plist: 'PlokeeShare/Info.plist',
    entitlements: 'PlokeeShare/PlokeeShare.entitlements'
  },
  {
    name: 'PlokeeWidget',
    bundle_suffix: 'Widget',
    deployment: '14.0',
    sources: ['PlokeeWidget/PlokeeWidget.swift'],
    info_plist: 'PlokeeWidget/Info.plist',
    entitlements: 'PlokeeWidget/PlokeeWidget.entitlements'
  }
].freeze

SHARED_SOURCE = 'PlokeeShared/PlokeeShared.swift'

project = Xcodeproj::Project.open(PROJECT)
app = project.targets.find { |t| t.name == 'Runner' }
raise 'Runner target not found' unless app

# --- Clean slate ------------------------------------------------------------

EXTENSIONS.each do |ext|
  project.targets.select { |t| t.name == ext[:name] }.each do |target|
    app.dependencies.select { |d| d.target == target }.each(&:remove_from_project)
    project.native_targets.each do |host|
      host.copy_files_build_phases.each do |phase|
        phase.files.select { |f| f.file_ref == target.product_reference }
             .each(&:remove_from_project)
      end
    end
    target.product_reference&.remove_from_project
    target.remove_from_project
  end
  project.main_group[ext[:name]]&.remove_from_project
end
project.main_group['PlokeeShared']&.remove_from_project

# Anything this script added to Runner on a previous run goes too — a file
# reference orphaned from its removed group resolves against the wrong
# directory, and the build fails on a path that does not exist.
OUR_APP_FILES = ['PlokeeShared.swift', 'PlokeeIntents.swift',
                 'PlokeeBridge.swift', 'Runner.entitlements'].freeze
project.files.select { |f| OUR_APP_FILES.include?(File.basename(f.path.to_s)) }
       .each(&:remove_from_project)

# --- Shared code ------------------------------------------------------------

shared_group = project.main_group.new_group('PlokeeShared', 'PlokeeShared')
shared_ref = shared_group.new_reference(File.basename(SHARED_SOURCE))
# The app target needs it too: the bridge and the intents read the same
# container the extensions write to.
app.add_file_references([shared_ref])

runner_group = project.main_group['Runner']
app.add_file_references(
  %w[PlokeeIntents.swift PlokeeBridge.swift].map do |name|
    runner_group.new_reference(name)
  end
)
runner_group.new_reference('Runner.entitlements')

# The app needs the App Group too — it is the side that reads the inbox and
# writes what the widget shows.
app.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end

# --- Extension targets ------------------------------------------------------

embed_phase = app.copy_files_build_phases.find { |p| p.name == 'Embed Foundation Extensions' }
embed_phase ||= app.new_copy_files_build_phase('Embed Foundation Extensions')
embed_phase.symbol_dst_subfolder_spec = :plug_ins
embed_phase.run_only_for_deployment_postprocessing = '0'

EXTENSIONS.each do |ext|
  target = project.new_target(
    :app_extension, ext[:name], :ios, ext[:deployment], nil, :swift
  )

  group = project.main_group.new_group(ext[:name], ext[:name])
  refs = ext[:sources].map { |path| group.new_reference(File.basename(path)) }
  group.new_reference(File.basename(ext[:info_plist]))
  group.new_reference(File.basename(ext[:entitlements]))
  target.add_file_references(refs + [shared_ref])

  target.build_configurations.each do |config|
    settings = config.build_settings
    settings['PRODUCT_BUNDLE_IDENTIFIER'] = "#{APP_BUNDLE_ID}.#{ext[:bundle_suffix]}"
    settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
    settings['INFOPLIST_FILE'] = ext[:info_plist]
    settings['CODE_SIGN_ENTITLEMENTS'] = ext[:entitlements]
    settings['CODE_SIGN_STYLE'] = 'Automatic'
    settings['DEVELOPMENT_TEAM'] = TEAM
    settings['IPHONEOS_DEPLOYMENT_TARGET'] = ext[:deployment]
    settings['SWIFT_VERSION'] = '5.0'
    settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    settings['SKIP_INSTALL'] = 'YES'
    # Extensions must not link a main(); they are dylibs loaded by the host.
    settings['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
    settings['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
    settings['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
    settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  end

  app.add_dependency(target)
  build_file = embed_phase.add_file_reference(target.product_reference)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
end

# Order matters. Xcode appends new phases at the end, which puts this after
# Flutter's "Thin Binary" script — and since both write into Runner.app, the
# build graph closes into a cycle and refuses to run. Embedding has to happen
# before Thin Binary, exactly where Xcode itself would put it.
app.build_phases.delete(embed_phase)
thin_binary = app.build_phases.index do |phase|
  phase.respond_to?(:name) && phase.name == 'Thin Binary'
end
app.build_phases.insert(thin_binary || app.build_phases.length, embed_phase)

project.save
puts "Added #{EXTENSIONS.map { |e| e[:name] }.join(', ')} to #{PROJECT}"
