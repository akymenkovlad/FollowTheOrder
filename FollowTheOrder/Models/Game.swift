//
//  Game.swift
//  FollowTheOrder
//
//  Created by Valados on 12.12.2021.
//

import Foundation

class Game {
    var level:Int
    
    var playlist = [Int]()
    var currentItem = 0
    var numberOfTaps = 0
    var readyForUser:Bool = false
    var elements:Int
    
    init() {
        level = 1
        elements = 5
        createPlaylist()
    }
    init(level:Int) {
        elements = 4+level
        self.level = level
        createPlaylist()
    }
    func createPlaylist(){
        for _ in 0..<elements{
            var randomNumber = Int(arc4random_uniform(UInt32(elements))+1)
            print(randomNumber)
            while (playlist.contains(randomNumber)){
                randomNumber = Int(arc4random_uniform(UInt32(elements))+1)
            }
            playlist.append(randomNumber)

        }
    }
}

struct Wish:Codable{
    var fortune:String?
}

enum Emoji: String,CaseIterable{
    case anger = "anger_emoji"
    case love = "love_emoji"
    case sad = "sad_emoji"
    case laughter = "laughter_emoji"
    case cool = "cool_emoji"
    case sick = "sick_emoji"
    case shocked = "shocked_emoji"
    case tease = "tease_emoji"
    case hug = "hug_emoji"
    case cry = "cry_emoji"
    case angel = "angel_emoji"
}
