import Parallaxer
import RxSwift
import RxCocoa
import UIKit

public final class InteractiveParallaxView: UIView {

    public let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isContinuous = true
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.backgroundColor = .blue
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
