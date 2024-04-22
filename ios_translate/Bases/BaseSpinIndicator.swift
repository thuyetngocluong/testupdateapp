//
//  BaseSpinIndicator.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit
import Combine
import Lottie

class BaseSpinIndicator: NSView {
    
    @Published var isLoading = false
    
    private let indicator: NSProgressIndicator = {
        let process = NSProgressIndicator()
        process.style = .spinning
        process.set(tintColor: .white)
        return process
    }()
    private let lottieView = LottieAnimationView()
    
    private var subscriptions = Set<AnyCancellable>()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private
    func setup() {
        
        addSubview(lottieView)
        lottieView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.top.greaterThanOrEqualToSuperview().inset(2)
        }
        lottieView.animation = .named("anim_spinner")
        lottieView.loopMode = .loop
        lottieView.animationSpeed = 1.5
        lottieView.play()
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.lightGray.cgColor
        
        $isLoading
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                self.alphaValue = isLoading ? 1 : 0
                if isLoading {
                    
                    self.indicator.startAnimation(nil)
                } else {
                    self.indicator.stopAnimation(nil)
                }
            }
            .store(in: &subscriptions)
    }
}
