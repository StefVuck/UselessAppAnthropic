import SwiftUI

enum ClippyExpression: String {
    case idle = "paperclip"
    case happy = "face.smiling"
    case evil = "face.smiling.inverse"
    case confused = "questionmark.circle.fill"
    case mischievous = "theatermasks.fill"
    case nervous = "drop.fill"
    case celebrating = "party.popper.fill"

    var symbolName: String {
        rawValue
    }
}

enum ClippyState {
    case hidden
    case idle
    case watching
    case throwing
    case teleporting
    case celebrating
    case mourning
}

struct ClippyMessage {
    let text: String
    let expression: ClippyExpression
    let duration: TimeInterval

    static let deleteMessages = [
        ClippyMessage(text: "Oops! Butterfingers!", expression: .evil, duration: 3.0),
        ClippyMessage(text: "Into the void it goes!", expression: .mischievous, duration: 3.0),
        ClippyMessage(text: "Don't worry, it's... mostly safe.", expression: .nervous, duration: 3.5),
        ClippyMessage(text: "I'm sure you didn't need that.", expression: .evil, duration: 3.0),
        ClippyMessage(text: "YEET!", expression: .celebrating, duration: 2.5),
        ClippyMessage(text: "Gone, but not forgotten... yet.", expression: .mischievous, duration: 3.5),
    ]

    static let teleportMessages = [
        ClippyMessage(text: "Now you see it, now you don't!", expression: .mischievous, duration: 3.0),
        ClippyMessage(text: "Portal time! Good luck finding it!", expression: .evil, duration: 3.5),
        ClippyMessage(text: "Beam me up, Scotty!", expression: .celebrating, duration: 2.5),
        ClippyMessage(text: "It's on an adventure now!", expression: .happy, duration: 3.0),
        ClippyMessage(text: "Hide and seek champion!", expression: .mischievous, duration: 3.0),
        ClippyMessage(text: "Surprise relocation!", expression: .evil, duration: 2.5),
    ]

    static let openMessages = [
        ClippyMessage(text: "Your wish is my command!", expression: .happy, duration: 2.5),
        ClippyMessage(text: "One successful file opening!", expression: .celebrating, duration: 3.0),
        ClippyMessage(text: "Wow, you got lucky this time!", expression: .happy, duration: 3.0),
        ClippyMessage(text: "The odds were in your favor!", expression: .celebrating, duration: 3.0),
        ClippyMessage(text: "How boring... it just worked.", expression: .confused, duration: 3.0),
    ]

    static let spinningMessages = [
        ClippyMessage(text: "Let's see what fate has in store...", expression: .nervous, duration: 4.0),
        ClippyMessage(text: "Round and round we go!", expression: .mischievous, duration: 4.0),
        ClippyMessage(text: "Feeling lucky?", expression: .evil, duration: 4.0),
        ClippyMessage(text: "Place your bets!", expression: .mischievous, duration: 4.0),
    ]
}
