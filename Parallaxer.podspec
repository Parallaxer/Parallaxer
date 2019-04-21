Pod::Spec.new do |s|
  s.name                      = "Parallaxer"
  s.version                   = "4.0.0"
  s.summary                   = "A framework for composing parallax effects in Swift."
  s.homepage                  = "https://github.com/Parallaxer/Parallaxer"
  s.license                   = "MIT"
  s.author                    = { "Clifton Roberts" => "clifton.roberts@me.com" }
  s.ios.deployment_target     = "10.0"
  s.source                    = { :git => "https://github.com/Parallaxer/Parallaxer.git",
                                  :tag => s.version.to_s }
  s.swift_version             = "4.2"

  s.default_subspec           = "Core"

  ### All functionality, with external dependencies.
  s.subspec "Core" do |ss|
    ss.dependency "Parallaxer/Base"
    ss.dependency "Parallaxer/Rx"
  end

  ### Base Parallaxer implementation, without external dependencies.
  s.subspec "Base" do |ss|
    ss.source_files = "Sources/Base/**/*.swift"
  end

  ### RxSwift integration
  s.subspec "Rx" do |ss|
    ss.dependency "RxSwift"
    ss.dependency "RxCocoa"
    ss.source_files = "Sources/Rx/**/*.swift"
  end
end
