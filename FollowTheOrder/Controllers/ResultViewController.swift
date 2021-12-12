//
//  ResultViewController.swift
//  FollowTheOrder
//
//  Created by Valados on 12.12.2021.
//

import UIKit
import Alamofire

class ResultViewController: UIViewController {

    var isVictory = false
    
    weak var delegate: RoundDelegate?
    
    private let resultLabel:UILabel = {
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
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .cyan
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startNewRound), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        if isVictory{
            fetchWish()
        }
        else{
            resultLabel.text = "Oooops"
            playAgainButton.isHidden = false
        }
        
    }
    
    func configureUI(){
        var constraints = [NSLayoutConstraint]()
        
        view.addSubview(resultLabel)
        view.addSubview(playAgainButton)
        
        constraints.append(resultLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor))
        constraints.append(resultLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30))
        constraints.append(resultLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30))
        
        constraints.append(playAgainButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor,constant: 30))
        constraints.append(playAgainButton.leftAnchor.constraint(equalTo: resultLabel.leftAnchor,constant: 100))
        constraints.append(playAgainButton.rightAnchor.constraint(equalTo: resultLabel.rightAnchor,constant: -100))
        
        NSLayoutConstraint.activate(constraints)
    }

    @objc func startNewRound(){
        dismiss(animated: true, completion: nil)
        let level = UserDefaults.standard.value(forKey: "level") as! Int
        if isVictory {
            UserDefaults.standard.set(level+1, forKey: "level")
            delegate?.playAgainButtonWasPressed(with: level+1)
        }
        else{
            delegate?.playAgainButtonWasPressed(with: level)
        }
        
        
    }
    
    func fetchWish(){
        AF.request("http://yerkee.com/api/fortune")
        .validate()
        .responseDecodable(of: Wish.self) { [weak self] response in
            guard let wish = response.value else { return }
              print(wish.fortune!)
            self?.resultLabel.text = wish.fortune
            self?.playAgainButton.isHidden = false
        }
    }
}
