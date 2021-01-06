import Parallaxer
import RxSwift
import RxCocoa
import UIKit

public final class InteractiveParallaxView: UIView {
    
    private struct Constants {
        
        static let sliderBackgroundColor = UIColor(red: 32/255, green: 203/255, blue: 204/255, alpha: 1)
        static let sliderFillColor = UIColor(red: 32/255, green: 203/255, blue: 204/255, alpha: 1)
    }

    public let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isContinuous = true
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.backgroundColor = UIColor(red: 29/255, green: 33/255, blue: 38/255, alpha: 1)
        slider.tintColor = UIColor(red: 127/255, green: 128/255, blue: 129/255, alpha: 1)
        slider.thumbTintColor = Constants.sliderBackgroundColor
        return slider
    }()

    public let visualizer: ParallaxView = {
        let visualizer = ParallaxView()
        visualizer.translatesAutoresizingMaskIntoConstraints = false
        return visualizer
    }()

    private let disposeBag = DisposeBag()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        addSubview(slider)
        slider.heightAnchor.constraint(equalToConstant: 40).isActive = true
        slider.topAnchor.constraint(equalTo: topAnchor).isActive = true
        slider.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        slider.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        addSubview(visualizer)
        visualizer.topAnchor.constraint(equalTo: slider.bottomAnchor).isActive = true
        visualizer.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        visualizer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        visualizer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
