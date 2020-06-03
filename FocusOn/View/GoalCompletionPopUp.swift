//
//  goalCompletionPopUp.swift
//  FocusOn
//
//  Created by Michael Gresham on 06/05/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//


import Foundation
import UIKit
import SAConfettiView

class GoalCompletionPopUp: UIView {
var messageLabel = UILabel()
var emojiLabel = UILabel()
var okButton = UIButton()

    private func configure() {
        // Set up view size and position
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        let popUP = UIView(frame: CGRect(x: (width-250)/2 , y: (height-250)/2, width: 250, height: 250))
        
        // Add Shadow To View
        let shadowLayer = CAShapeLayer()
        shadowLayer.fillColor = UIColor.init(red: 28/255, green: 35/255, blue: 33/255, alpha: 1).cgColor
        shadowLayer.path = UIBezierPath(roundedRect: popUP.bounds, cornerRadius: 25).cgPath
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.2
        shadowLayer.shadowRadius = 3
        popUP.layer.insertSublayer(shadowLayer, at: 0)
        
        // Set up message label
        messageLabel.textColor = UIColor.white
        messageLabel.font = UIFont(name: "Avenir-Heavy", size: 20)
        messageLabel.frame = CGRect(x: 20, y: 0, width: 210, height: 50)
        messageLabel.textAlignment = .center
        popUP.addSubview(messageLabel)
        
        // Set up emoji label
        emojiLabel.font = UIFont(name: "Avenir-Heavy", size: 75)
        emojiLabel.frame = CGRect(x: 20, y: 50, width: 210, height: 140)
        emojiLabel.textAlignment = .center
        popUP.addSubview(emojiLabel)
        
        // Set up button appearance
        okButton.frame = CGRect(x: 20, y: 190, width: 210, height: 44)
        okButton.layer.cornerRadius = 22
        okButton.backgroundColor = UIColor.white
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(UIColor.black, for: .normal)
        okButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 20)
        okButton.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        popUP.addSubview(okButton)
        
        let confettiView = SAConfettiView(frame: UIScreen.main.bounds)
        confettiView.startConfetti()
        self.addSubview(confettiView)
        self.addSubview(popUP)
        self.alpha = 0
    }

    func animatePopUp(_ sender: UITableViewController){
        configure()
        //When Goal is marked as completed, present Pop Up
        let message = "Goal Completed! "
        let feedback = ["👍", "👌", "😁", "🤩", "🤙", "💪", "🤟", "🥳", "🤗"]
        messageLabel.text = message
        emojiLabel.text = feedback[Int.random(in: 0 ..< feedback.count)]
        self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    @objc func buttonTapped(sender: UIButton) {
        // Dismiss View
        UIView.animate(withDuration: 0.2, delay: 0, options:
            UIView.AnimationOptions.transitionFlipFromTop, animations: {
            self.alpha = 0
            //self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { finished in
            self.removeFromSuperview()
        })
    }
}
