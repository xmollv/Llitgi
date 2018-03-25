project 'llitgi/llitgi.xcodeproj'
platform :ios, '11.0'

inhibit_all_warnings!
use_frameworks!

def app_pods
    pod 'Fabric'
    pod 'Crashlytics'
end

target 'Llitgi' do
    app_pods
end

target 'ShareExtension' do
    app_pods
end

plugin 'cocoapods-keys', {
    :project => "Llitgi",
    :keys => [
    "TEST"
    ]}
