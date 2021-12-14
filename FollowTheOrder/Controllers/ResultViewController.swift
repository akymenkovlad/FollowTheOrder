//
//  ResultViewController.swift
//  FollowTheOrder
//
//  Created by Valados on 12.12.2021.
//

import UIKit
import Alamofire
import SpriteKit
import JGProgressHUD

class ResultViewController: UIViewController {
    
    //MARK: UI elements
    var isVictory = false
    
    weak var delegate: RoundDelegate?
    
    private let skView = SKView()
    private let spinner = JGProgressHUD(style: .dark)
    
    private let resultLabel:UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "Marker Felt Thin", size: 40)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 20
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Marker Felt Thin", size: 25)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 20
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playAgainButton:UIButton = {
        let button = UIButton()
        button.setTitle("Play Again", for: .normal)
        button.isHidden = true
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemYellow
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startNewRound), for: .touchUpInside)
        return button
    }()
    //MARK: View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        spinner.show(in: view)
        configureUI()
        if isVictory{
            fetchWish()
        }
        else{
            spinner.dismiss(animated: true)
            messageLabel.text = "Oooops"
            resultLabel.text = "Lose"
            playAgainButton.isHidden = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        let level = UserDefaults.standard.value(forKey: "level") as! Int
        if isVictory {
            UserDefaults.standard.set(level+1, forKey: "level")
            delegate?.playAgainButtonWasPressed(with: level+1)
        }
        else{
            delegate?.playAgainButtonWasPressed(with: level)
        }
    }
    private func configureUI(){
        var constraints = [NSLayoutConstraint]()
        
        skView.frame = view.bounds
        skView.backgroundColor = .clear
        
        view.addSubview(resultLabel)
        view.addSubview(messageLabel)
        view.addSubview(playAgainButton)

        constraints.append(resultLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        constraints.append(resultLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 50))
        constraints.append(resultLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -50))
        
        constraints.append(messageLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor))
        constraints.append(messageLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30))
        constraints.append(messageLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30))
        
        constraints.append(playAgainButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor,constant: 30))
        constraints.append(playAgainButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,constant: 50))
        constraints.append(playAgainButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,constant: -50))
        
                
        NSLayoutConstraint.activate(constraints)
    }
    @objc func startNewRound(){
        dismiss(animated: true, completion: nil)
    }
    //MARK: Victory case functions
    private func fetchWish(){
        AF.request("http://yerkee.com/api/fortune")
            .validate()
            .responseDecodable(of: Wish.self) { [weak self] response in
                guard let self = self else{return}
                self.spinner.dismiss(animated: true)
                self.playAgainButton.isHidden = false
                self.resultLabel.text = "Victory"
                guard let wish = response.value else {
                    self.messageLabel.text = "You won!!!"
                    self.showWinAnimation()
                    return
                }
                print(wish.fortune!)
                self.messageLabel.text = wish.fortune
                self.showWinAnimation()
            }
    }
    private func showWinAnimation(){
        if isVictory{
            view.addSubview(skView)
            let scene: SKScene = SKScene(size: view.bounds.size)
            scene.scaleMode = .aspectFit
            scene.backgroundColor = .clear
            let en = SKEmitterNode(fileNamed: "VictoryParticle.sks")
            let en1 = SKEmitterNode(fileNamed: "VictoryParticle.sks")
            let en2 = SKEmitterNode(fileNamed: "VictoryParticle.sks")
            en?.position = CGPoint(x: 0, y: view.viewHeight)
            scene.addChild(en!)
            en1?.position = CGPoint(x: view.viewWidth, y: view.viewHeight)
            scene.addChild(en1!)
            en2?.position = CGPoint(x: view.viewWidth/2, y: view.viewHeight/2)
            scene.addChild(en2!)
            skView.presentScene(scene)
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: { [weak self] in
                self?.skView.removeFromSuperview()
            })
        }
    }
}
