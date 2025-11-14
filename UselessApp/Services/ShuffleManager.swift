//
//  ShuffleManager.swift
//  UselessApp
//
//  Created by Claude on 2025-11-14.
//

import Foundation
import SwiftUI

class ShuffleManager: ObservableObject {
    @Published var currentFolder: [FileItem] = []
    @Published var currentShuffleType: ShuffleType?
    @Published var shuffleCount: Int = 0
    @Published var todayShuffleCount: Int = 0
    
    private var shuffleHistory: [(date: Date, type: ShuffleType, itemCount: Int)] = []
    private var lastShuffleDate: Date?
    
    init() {
        resetDailyCountIfNeeded()
    }
    
    // MARK: - Public Methods
    
    /// Shuffles the folder contents using a random shuffle algorithm
    func shuffleFolder(_ items: [FileItem]) -> [FileItem] {
        let shuffleType = ShuffleType.allCases.randomElement()!
        return shuffleFolder(items, with: shuffleType)
    }
    
    /// Shuffles the folder contents using a specific algorithm
    func shuffleFolder(_ items: [FileItem], with type: ShuffleType) -> [FileItem] {
        resetDailyCountIfNeeded()
        
        let shuffled = applyShuffleAlgorithm(items, type: type)
        
        currentFolder = shuffled
        currentShuffleType = type
        shuffleCount += 1
        todayShuffleCount += 1
        
        shuffleHistory.append((date: Date(), type: type, itemCount: items.count))
        
        return shuffled
    }
    
    /// "Undo" function that just re-shuffles with a different algorithm
    func undoShuffle(_ items: [FileItem]) -> [FileItem] {
        // Comedy: "undo" just shuffles again with a different type
        let differentTypes = ShuffleType.allCases.filter { $0 != currentShuffleType }
        let newType = differentTypes.randomElement() ?? .random
        return shuffleFolder(items, with: newType)
    }
    
    func getStatistics() -> ShuffleStatistics {
        ShuffleStatistics(
            totalShuffles: shuffleCount,
            todayShuffles: todayShuffleCount,
            favoriteType: getMostUsedShuffleType(),
            averageItemsShuffled: getAverageItemCount()
        )
    }
    
    // MARK: - Private Shuffle Algorithms
    
    private func applyShuffleAlgorithm(_ items: [FileItem], type: ShuffleType) -> [FileItem] {
        switch type {
        case .random:
            return randomChaos(items)
            
        case .reverseAlpha:
            return reverseAlphabetical(items)
            
        case .sizeSort:
            return sizeSort(items)
            
        case .extensionChaos:
            return extensionChaos(items)
            
        case .dateChaos:
            return dateChaos(items)
            
        case .fibonacci:
            return fibonacciPositions(items)
        }
    }
    
    // Algorithm 1: Pure Random Shuffle
    private func randomChaos(_ items: [FileItem]) -> [FileItem] {
        return items.shuffled()
    }
    
    // Algorithm 2: Reverse Alphabetical (Z to A)
    private func reverseAlphabetical(_ items: [FileItem]) -> [FileItem] {
        return items.sorted { $0.name.lowercased() > $1.name.lowercased() }
    }
    
    // Algorithm 3: Sort by Size (Smallest First)
    private func sizeSort(_ items: [FileItem]) -> [FileItem] {
        return items.sorted { $0.size < $1.size }
    }
    
    // Algorithm 4: Extension Chaos
    private func extensionChaos(_ items: [FileItem]) -> [FileItem] {
        // Group by extension, then randomize within groups
        let grouped = Dictionary(grouping: items) { item -> String in
            if item.isDirectory {
                return "📁_folders"
            }
            return (item.path.pathExtension.isEmpty ? "no_extension" : item.path.pathExtension)
        }
        
        var result: [FileItem] = []
        for (_, group) in grouped.sorted(by: { $0.key < $1.key }) {
            result.append(contentsOf: group.shuffled())
        }
        
        return result
    }
    
    // Algorithm 5: Date Chaos (Sort by creation date with second precision)
    private func dateChaos(_ items: [FileItem]) -> [FileItem] {
        return items.sorted { $0.creationDate < $1.creationDate }
    }
    
    // Algorithm 6: Fibonacci Positions
    private func fibonacciPositions(_ items: [FileItem]) -> [FileItem] {
        guard items.count > 0 else { return items }
        
        var shuffled = items.shuffled()
        var result = Array(repeating: FileItem?.none, count: items.count)
        
        // Generate Fibonacci positions up to array length
        var fibPositions: [Int] = []
        var a = 0, b = 1
        
        while b < items.count {
            fibPositions.append(b)
            let temp = a + b
            a = b
            b = temp
        }
        
        // Place items at Fibonacci positions first
        for (index, fibPos) in fibPositions.enumerated() where index < shuffled.count {
            result[fibPos] = shuffled[index]
        }
        
        // Fill remaining positions
        var remainingIndex = fibPositions.count
        for i in 0..<result.count where result[i] == nil && remainingIndex < shuffled.count {
            result[i] = shuffled[remainingIndex]
            remainingIndex += 1
        }
        
        return result.compactMap { $0 }
    }
    
    // MARK: - Statistics Helpers
    
    private func resetDailyCountIfNeeded() {
        let calendar = Calendar.current
        
        if let lastDate = lastShuffleDate {
            if !calendar.isDateInToday(lastDate) {
                todayShuffleCount = 0
            }
        }
        
        lastShuffleDate = Date()
    }
    
    private func getMostUsedShuffleType() -> ShuffleType? {
        let typeCounts = Dictionary(grouping: shuffleHistory, by: { $0.type })
            .mapValues { $0.count }
        
        return typeCounts.max(by: { $0.value < $1.value })?.key
    }
    
    private func getAverageItemCount() -> Double {
        guard !shuffleHistory.isEmpty else { return 0.0 }
        let total = shuffleHistory.reduce(0) { $0 + $1.itemCount }
        return Double(total) / Double(shuffleHistory.count)
    }
}

// MARK: - Supporting Types

struct ShuffleStatistics {
    let totalShuffles: Int
    let todayShuffles: Int
    let favoriteType: ShuffleType?
    let averageItemsShuffled: Double
    
    var chaosLevel: Int {
        // Comedy metric: 0-100 based on shuffle intensity
        min(100, todayShuffles * 10 + totalShuffles / 10)
    }
}
