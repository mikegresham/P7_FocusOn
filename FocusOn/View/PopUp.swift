//
//  PopUp.swift
//  FocusOn
//
//  Created by Michael Gresham on 05/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

class PopUp: UIView {
var label = UILabel()

    private func configure() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        self.frame = CGRect(x: (width-250)/2 , y: height, width: 250, height: 50)
        label.textColor = UIColor.white
        label.font = UIFont(name: "Avenir-Heavy", size: 20)
        label.frame = CGRect(x: 20, y: 0, width: 210, height: 50)
        label.textAlignment = .center
        self.addSubview(label)
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.fillColor = UIColor.init(red: 0/255, green: 166/255, blue: 118/255, alpha: 1).cgColor
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 25).cgPath
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.2
        shadowLayer.shadowRadius = 3

        self.layer.insertSublayer(shadowLayer, at: 0)
        self.alpha = 0
    }

    func animateSuccessPopUp(){
        let message = ["Good Job! ", "Well Done ", "Keep It Up! ", "Awesome! ", "Nice One! ", "Great Progress! "]
        let feedback = ["👍", "👌", "😁", "🤩", "🤙", "💪", "🤟", "🥳", "🤗"]
        label.text = message[Int.random(in: 0 ..< message.count)] + feedback[Int.random(in: 0 ..< feedback.count)]
        animate()
    }
    func animateFailPopUp(){
        let message = ["Maybe Next Time! ", "Keep Trying ", "Oh Well! ", "Don't Give Up! ", "So Close! ", "Nearly Had It! "]
        let feedback = ["😣", "😢", "😓", "🤦‍♂️", "😩", "😭", "😖", "🤷‍♂️", "🥺"]
        label.text = message[Int.random(in: 0 ..< message.count)] + feedback[Int.random(in: 0 ..< feedback.count)]
        animate()
    }
    private func animate() {
        configure()

        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -165)
            self.alpha = 1
        })
        UIView.animate(withDuration: 0.3, delay: 1.2, options:
            UIView.AnimationOptions.transitionFlipFromTop, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: 165)
        }, completion: { finished in
            self.removeFromSuperview()
        })
    }
}
