Pod::Spec.new do |s|
  s.name                      = "Parallaxer"
  s.version                   = "3.0.2"
  s.summary                   = "A framework for composing parallax effects in Swift."
  s.homepage                  = "https://github.com/Parallaxer/Parallaxer"
  s.license                   = "MIT"
  s.author                    = { "Clifton Roberts" => "clifton.roberts@me.com" }
  s.ios.deployment_target     = "8.0"
  s.osx.deployment_target     = "10.10"
  s.tvos.deployment_target    = "9.0"
  s.watchos.deployment_target = "2.0"
  s.source                    = { :git => "https://github.com/Parallaxer/Parallaxer.git",
                                  :tag => s.version.to_s }
  s.swift_version             = "4.2"
  s.source_files              = "Sources/**/*.swift"
  s.module_name               = "Parallaxer"
end
