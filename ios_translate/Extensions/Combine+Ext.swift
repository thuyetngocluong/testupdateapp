//
//  Combine+Ext.swift
//  ios_translate
//
//  Created by ThuyetLN on 19/4/24.
//

import AppKit
import Combine


extension NSTextField {
    var textPulisher: AnyPublisher<String, Never> {
        Combine.Publishers.NSTextFieldPublisher(control: self).eraseToAnyPublisher()
    }
    

}

extension Combine.Publishers {
    struct NSTextFieldPublisher: Publisher {
        typealias Output = String
        typealias Failure = Never
        
        private let control: NSTextField
        
        init(control: NSTextField) {
            self.control = control
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, String == S.Input {
            let subscription = NSTextFieldSubscription(subscriber: subscriber, control: control)

            subscriber.receive(subscription: subscription)
        }
    }
}

extension Combine.Publishers.NSTextFieldPublisher {
    final class NSTextFieldSubscription<S: Subscriber>: NSObject, Combine.Subscription, NSTextFieldDelegate where S.Input == String {
        
        private var subscriber: S?
        weak private var control: NSTextField?
        private var didEmitInitial = false
        
        
        init(subscriber: S, control: NSTextField) {
            self.subscriber = subscriber
            self.control = control
            super.init()
            control.delegate = self
        }
        
        func request(_ demand: Subscribers.Demand) {
//            if !didEmitInitial,
//                demand > .none,
//                let control = control,
//                let subscriber = subscriber {
//                _ = subscriber.receive(control.stringValue)
//                didEmitInitial = true
//            }
        }
        
        func cancel() {
            
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let control = self.control else { return }
            _ = subscriber?.receive(control.stringValue)
        }
    }
}
