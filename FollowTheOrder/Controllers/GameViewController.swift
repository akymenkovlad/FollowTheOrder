//
//  ViewController.swift
//  FollowTheOrder
//
//  Created by Valados on 12.12.2021.
//

import UIKit

protocol RoundDelegate: AnyObject {
    func playAgainButtonWasPressed(with round:Int)
}

class GameViewController: UIViewController {
    
    var game:Game?
    
    //MARK: Configure UI Elements
    private let levelLabel:UILabel = {
        let label = UILabel()
        label.text = "Follow the Order"
        label.font = UIFont(name: "Marker Felt Thin", size: 40)
        label.textAlignment = .center
        label.textColor = .label
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let startGameButton:UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "start"), for: .normal)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startGame(sender:)), for: .touchUpInside)
        return button
    }()
    
    private var gameButton = [UIButton]()
    
    private let gameView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //MARK: Controller lifecycle and constraints
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.object(forKey: "level") == nil {
            UserDefaults.standard.set(1, forKey: "level")
        }
        view.backgroundColor = .systemBackground
        configureUI()
    }
    
    
    private func configureUI(){
        var constraints = [NSLayoutConstraint]()
        
        view.addSubview(levelLabel)
        view.addSubview(gameView)
        view.addSubview(logoImageView)
        gameView.addSubview(startGameButton)
        
        constraints.append(levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        constraints.append(levelLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor))
        
        constraints.append(logoImageView.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 100))
        constraints.append(logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor))
        constraints.append(logoImageView.heightAnchor.constraint(equalToConstant: 300))
        constraints.append(logoImageView.widthAnchor.constraint(equalToConstant: 300))
        
        constraints.append(gameView.topAnchor.constraint(equalTo: levelLabel.topAnchor, constant: 50))
        constraints.append(gameView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor))
        constraints.append(gameView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        constraints.append(gameView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor))
        
        constraints.append(startGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(startGameButton.topAnchor.constraint(equalTo: logoImageView.bottomAnchor,constant: 50))
        constraints.append(startGameButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,constant: 20))
        constraints.append(startGameButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,constant: -20))
        constraints.append(startGameButton.heightAnchor.constraint(equalToConstant: 200))
        
        NSLayoutConstraint.activate(constraints)
    }
    private func moveToRandomPosition(button:UIButton){
        let buttonWidth = button.frame.width
        let buttonHeight = button.frame.height
        
        // Compute width and height of the area to contain the button's center
        let xwidth = gameView.viewWidth - buttonWidth
        let yheight = gameView.viewHeight - buttonHeight
        
        var xoffset = CGFloat(0)
        var yoffset = CGFloat(0)
        var check = true
        //Check if gameButtons are collided
        while check {
            check = false
            xoffset = CGFloat(arc4random_uniform(UInt32(xwidth)))+(buttonWidth/2)
            yoffset = CGFloat(arc4random_uniform(UInt32(yheight)))+(buttonHeight/2)
            for btn in gameButton {
                if button.tag != btn.tag{
                    if abs(xoffset - btn.center.x) <= buttonWidth, abs(yoffset - btn.center.y) <= buttonHeight{
                        print("Emojis collide")
                        print(btn.center.x)
                        print(xoffset)
                        print(btn.center.y)
                        print(yoffset)
                        check = true
                    }
                }
            }
        }
        // Offset the button's center by the random offsets.
        button.center.x = xoffset
        button.center.y = yoffset
        print("Button \(button.tag) cordinates x:\(button.center.x) y:\(button.center.y)")
    }
    //MARK: Game logic functions
    private func showNextItem(){
        guard let game = game else{
            print("game object is nil")
            return
        }
        if game.currentItem <= game.playlist.count-1{
            let selectedItem = game.playlist[game.currentItem]
            switch selectedItem{
            case 1...game.elements:
                print(selectedItem)
                animateButtonWithTag(tag: selectedItem)
                break
            default:
                break
            }
            game.currentItem += 1
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                self.showNextItem()
            })
            
        }
        else{
            game.readyForUser = true
            enableButtons(state: true)
        }
    }
    
    func checkIfCorrect(_ button:Int){
        print(button)
        guard let game = game else{
            print("game object is nil")
            return
        }
        if button == game.playlist[game.numberOfTaps] {
            if game.numberOfTaps == game.playlist.count-1 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    let vc = ResultViewController()
                    vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .coverVertical
                    vc.isVictory = true
                    vc.delegate = self
                    self.present(vc, animated: true, completion: nil)
                })
                return
            }
            game.numberOfTaps += 1
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                let vc = ResultViewController()
                vc.delegate = self
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .coverVertical
                self.present(vc, animated: true, completion: nil)
            })
        }
    }
    //MARK: Configure button actions
    private func createGameButton(with name:String,tag:Int)->UIButton{
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 80)))
        button.setBackgroundImage(UIImage(named: name), for: .normal)
        button.clipsToBounds = true
        button.tag = tag
        button.isHidden = true
        button.addTarget(self, action: #selector(gameItemPressed), for: .touchUpInside)
        return button
    }
    
    @objc func startGame(sender: AnyObject){
        
        if !gameButton.isEmpty{
            gameButton.removeAll()
        }
        game = Game(level: UserDefaults.standard.value(forKey: "level") as! Int)
        dump(game)
        enableButtons(state: false)
        guard let game = game else{
            print("game object is nil")
            return
        }
        for i in 0..<game.elements {
            let index = Int(arc4random_uniform(UInt32(Emoji.allCases.count)))
            gameButton.append(createGameButton(with:Emoji.allCases[index].rawValue, tag: i+1))
            gameView.addSubview(gameButton[i])
        }
        levelLabel.text = "Level \(game.level)"
        for button in gameButton {
            moveToRandomPosition(button: button)
            button.isHidden = false
        }
        startGameButton.isHidden = true
        logoImageView.isHidden = true
        showNextItem()
    }
    
    @objc func gameItemPressed(sender: AnyObject){
        guard let game = game else{
            print("game object is nil")
            return
        }
        if game.readyForUser{
            let button = sender as! UIButton
            animateButton(sender: button)
            switch button.tag {
            case 0...game.elements:
                checkIfCorrect(button.tag)
            default:
                break
            }
        }
    }
    
    private func animateButtonWithTag(tag:Int){
        let button = gameButton[tag-1]
        animateButton(sender: button)
    }
    
    private func animateButton(sender: AnyObject){
        let button = sender as! UIButton
        let options: UIView.AnimationOptions = [.curveLinear]
        let width = button.frame.size.width
        let heigth = button.frame.size.height
        UIView.animate(withDuration: 0.2, delay: 0.0, options: options, animations: {
            button.frame.size.width*=1.5
            button.frame.size.height*=1.5
        }, completion: nil)
        UIView.animate(withDuration: 0.2, delay: 0.2, options: options, animations: {
            button.frame.size.width = width
            button.frame.size.height = heigth
        }, completion: nil)
    }
    
    func enableButtons(state:Bool){
        for button in gameButton {
            button.isUserInteractionEnabled = state
        }
    }
}
//MARK: RoundDelegate
extension GameViewController: RoundDelegate{
    func playAgainButtonWasPressed(with round: Int) {
        enableButtons(state: false)
        levelLabel.text = "Level \(round)"
        for button in gameButton {
            button.isHidden = true
        }
        if !gameButton.isEmpty{
            gameButton.removeAll()
        }
        startGameButton.isHidden = false
    }
}
