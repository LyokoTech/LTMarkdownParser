#
# Be sure to run `pod lib lint LTMarkdownParser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LTMarkdownParser"
  s.version          = "2.0.0"
  s.summary          = "A markdown parser written in swift"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
    A parser written to convert a string containing markdown to an NSAttributedString.  It was based off of TSMarkdownParser, but rewritten in Swift.
                       DESC

  s.homepage         = "https://github.com/LyokoTech/LTMarkdownParser"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Rhett Rogers" => "serenade.xs@icloud.com" }
  s.source           = { :git => "https://github.com/LyokoTech/LTMarkdownParser.git", :tag => s.version.to_s }

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.xcconfig = { 'SWIFT_VERSION' => '2.3' }
end
