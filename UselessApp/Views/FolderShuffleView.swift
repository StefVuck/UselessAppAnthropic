//
//  FolderShuffleView.swift
//  UselessApp
//
//  Created by Claude on 2025-11-14.
//

import SwiftUI

struct FolderShuffleView: View {
    @StateObject private var shuffleManager = ShuffleManager()
    @State private var items: [FileItem]
    @State private var shuffledItems: [FileItem]
    @State private var isShuffling = false
    @State private var showStatistics = false
    @State private var justShuffled = false
    
    let folderPath: URL
    let onFileSelected: (FileItem) -> Void
    let onFolderSelected: (FileItem) -> Void
    
    init(folderPath: URL, items: [FileItem], onFileSelected: @escaping (FileItem) -> Void, onFolderSelected: @escaping (FileItem) -> Void) {
        self.folderPath = folderPath
        self._items = State(initialValue: items)
        self._shuffledItems = State(initialValue: items)
        self.onFileSelected = onFileSelected
        self.onFolderSelected = onFolderSelected
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with shuffle info
            header
            
            Divider()
            
            // File list
            if shuffledItems.isEmpty {
                emptyFolderView
            } else {
                fileListView
            }
        }
        .onAppear {
            performInitialShuffle()
        }
        .sheet(isPresented: $showStatistics) {
            statisticsView
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 12) {
            // Folder path
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.blue)
                Text(folderPath.lastPathComponent)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                // Statistics button
                Button(action: { showStatistics = true }) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            
            // Shuffle type indicator
            if let currentType = shuffleManager.currentShuffleType {
                HStack(spacing: 8) {
                    Text(currentType.emoji)
                        .font(.title3)
                    
                    Text("Organized by: \(currentType.rawValue)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("Shuffled \(shuffleManager.todayShuffleCount) times today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor.opacity(0.1))
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .opacity
                ))
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: performShuffle) {
                    HStack {
                        Image(systemName: isShuffling ? "arrow.triangle.2.circlepath" : "shuffle")
                            .rotationEffect(.degrees(isShuffling ? 360 : 0))
                        Text("Shuffle Again")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isShuffling)
                
                Button(action: performUndo) {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Undo (Sort of)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(isShuffling || shuffleManager.shuffleCount == 0)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - File List
    
    private var fileListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(shuffledItems.enumerated()), id: \.element.id) { index, item in
                    FileRowView(item: item, index: index + 1)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleItemTap(item)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: shuffledItems.map(\.id))
        }
    }
    
    private var emptyFolderView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("This folder is empty")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Nothing to shuffle here!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Statistics View
    
    private var statisticsView: some View {
        VStack(spacing: 20) {
            Text("📊 Shuffle Statistics")
                .font(.title)
                .fontWeight(.bold)
            
            let stats = shuffleManager.getStatistics()
            
            VStack(spacing: 16) {
                StatRow(label: "Total Shuffles", value: "\(stats.totalShuffles)")
                StatRow(label: "Shuffles Today", value: "\(stats.todayShuffles)")
                StatRow(label: "Chaos Level", value: "\(stats.chaosLevel)%")
                
                if let favorite = stats.favoriteType {
                    StatRow(label: "Favorite Algorithm", value: "\(favorite.emoji) \(favorite.rawValue)")
                }
                
                StatRow(label: "Avg Items Shuffled", value: String(format: "%.1f", stats.averageItemsShuffled))
                
                // Chaos meter
                VStack(alignment: .leading, spacing: 8) {
                    Text("Chaos Meter")
                        .font(.headline)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 20)
                                .cornerRadius(10)
                            
                            Rectangle()
                                .fill(chaosColor(for: stats.chaosLevel))
                                .frame(width: geometry.size.width * CGFloat(stats.chaosLevel) / 100, height: 20)
                                .cornerRadius(10)
                                .animation(.spring(), value: stats.chaosLevel)
                        }
                    }
                    .frame(height: 20)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
            )
            
            Button("Close") {
                showStatistics = false
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
        .frame(width: 400, height: 500)
    }
    
    // MARK: - Actions
    
    private func performInitialShuffle() {
        // Shuffle on first appearance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            performShuffle()
        }
    }
    
    private func performShuffle() {
        guard !isShuffling else { return }
        
        isShuffling = true
        justShuffled = true
        
        // Simulate "organizing" delay for comedy
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                shuffledItems = shuffleManager.shuffleFolder(items)
            }
            
            isShuffling = false
            
            // Hide shuffle indicator after a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                justShuffled = false
            }
        }
    }
    
    private func performUndo() {
        guard !isShuffling else { return }
        
        isShuffling = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                shuffledItems = shuffleManager.undoShuffle(items)
            }
            
            isShuffling = false
        }
    }
    
    private func handleItemTap(_ item: FileItem) {
        if item.isDirectory {
            // Navigate to folder (will trigger another shuffle)
            onFolderSelected(item)
        } else {
            // Open file (will show Wheel of Doom)
            onFileSelected(item)
        }
    }
    
    // MARK: - Helpers
    
    private func chaosColor(for level: Int) -> Color {
        switch level {
        case 0..<30:
            return .green
        case 30..<60:
            return .yellow
        case 60..<80:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - Supporting Views

struct FileRowView: View {
    let item: FileItem
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Index number
            Text("\(index)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            
            // Icon
            Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                .foregroundColor(item.isDirectory ? .blue : .gray)
                .frame(width: 24)
            
            // Name
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                
                Text(item.isDirectory ? "Folder" : formatFileSize(item.size))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(6)
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    FolderShuffleView(
        folderPath: URL(fileURLWithPath: "/Users/test/Documents"),
        items: [
            FileItem(id: UUID(), name: "Document.pdf", path: URL(fileURLWithPath: "/test/doc.pdf"), size: 1024000, isDirectory: false, creationDate: Date(), displayName: "Document.pdf"),
            FileItem(id: UUID(), name: "Photos", path: URL(fileURLWithPath: "/test/photos"), size: 0, isDirectory: true, creationDate: Date(), displayName: "Photos"),
            FileItem(id: UUID(), name: "Notes.txt", path: URL(fileURLWithPath: "/test/notes.txt"), size: 2048, isDirectory: false, creationDate: Date(), displayName: "Notes.txt")
        ],
        onFileSelected: { _ in },
        onFolderSelected: { _ in }
    )
    .frame(width: 600, height: 800)
}
