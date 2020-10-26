Pod::Spec.new do |s|
  s.name         = "GSCXScanner"
  s.version      = "3.0.3"
  s.summary      = "iOS Accessibility Scanner."
  s.description  = <<-DESC
  iOS Accessibility scanner framework to catch a11y issues during development.
                   DESC
  s.homepage     = "https://github.com/google/GSCXScanner"
  s.license      = "Apache License 2.0"
  s.author       = "j-sid"
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/google/GSCXScanner.git", :tag => "3.0.3" }
  s.source_files = "Sources/**/*.{h,m,swift}"
  s.resources    = "Sources/**/*.{xib}"
  s.dependency 'GTXiLib'
end
