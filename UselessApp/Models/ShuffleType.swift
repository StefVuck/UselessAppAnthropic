//
//  ShuffleType.swift
//  UselessApp
//
//  Created by Claude on 2025-11-14.
//

import Foundation

enum ShuffleType: String, CaseIterable {
    case random = "Random Chaos"
    case reverseAlpha = "Z→A"
    case sizeSort = "Tiny First"
    case extensionChaos = "Extension Madness"
    case dateChaos = "Time Traveler"
    case fibonacci = "Fibonacci Positions"
    
    var description: String {
        switch self {
        case .random:
            return "Pure chaos - files scattered randomly"
        case .reverseAlpha:
            return "Reverse alphabetical order (Z to A)"
        case .sizeSort:
            return "Smallest files first (utterly useless)"
        case .extensionChaos:
            return "Grouped by extension, then randomized"
        case .dateChaos:
            return "Sorted by creation date down to the second"
        case .fibonacci:
            return "Files positioned at Fibonacci sequence indices"
        }
    }
    
    var emoji: String {
        switch self {
        case .random:
            return "🎲"
        case .reverseAlpha:
            return "🔄"
        case .sizeSort:
            return "📏"
        case .extensionChaos:
            return "🎨"
        case .dateChaos:
            return "⏰"
        case .fibonacci:
            return "🌀"
        }
    }
}
