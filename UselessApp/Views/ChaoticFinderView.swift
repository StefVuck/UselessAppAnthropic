//
//  ChaoticFinderView.swift
//  UselessApp
//
//  Created by Claude on 2025-11-14.
//

import SwiftUI

struct ChaoticFinderView: View {
    @StateObject private var fileService = FileSystemService.shared
    @State private var currentPath: URL
    @State private var navigationStack: [URL] = []
    @State private var selectedFile: FileItem?
    @State private var showWheel = false

    init() {
        let path = FileSystemService.shared.playgroundPath
        _currentPath = State(initialValue: path)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Navigation breadcrumb
                breadcrumbBar

                Divider()

                // Main content - FolderShuffleView
                let items = fileService.loadFiles(at: currentPath)

                if items.isEmpty {
                    emptyStateView
                } else {
                    FolderShuffleView(
                        folderPath: currentPath,
                        items: items,
                        onFileSelected: { file in
                            selectedFile = file
                            showWheel = true
                        },
                        onFolderSelected: { folder in
                            navigateToFolder(folder)
                        }
                    )
                }
            }
            .frame(minWidth: 700, minHeight: 600)
            .navigationTitle("Chaotic Finder")
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    if canGoBack {
                        Button(action: navigateBack) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: resetToRoot) {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }
            }
        }
        .sheet(isPresented: $showWheel) {
            if let file = selectedFile {
                WheelOfDoomView(file: file)
            }
        }
    }

    // MARK: - Breadcrumb Bar

    private var breadcrumbBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "folder.fill")
                .foregroundColor(.blue)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(pathComponents, id: \.self) { component in
                        Text(component)
                            .font(.caption)
                            .foregroundColor(.primary)

                        if component != pathComponents.last {
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Spacer()

            Text("\(fileService.loadFiles(at: currentPath).count) items")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var pathComponents: [String] {
        let playground = FileSystemService.shared.playgroundPath
        let relative = currentPath.path.replacingOccurrences(of: playground.path, with: "")

        if relative.isEmpty || relative == "/" {
            return ["ChaoticPlayground"]
        }

        let components = relative.split(separator: "/").map(String.init)
        return ["ChaoticPlayground"] + components
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("This folder is empty")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("Navigate back or go home to find files")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: resetToRoot) {
                Text("Go Home")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Navigation

    private var canGoBack: Bool {
        return !navigationStack.isEmpty
    }

    private func navigateToFolder(_ folder: FileItem) {
        navigationStack.append(currentPath)
        currentPath = folder.path
    }

    private func navigateBack() {
        guard let previous = navigationStack.popLast() else { return }
        currentPath = previous
    }

    private func resetToRoot() {
        navigationStack.removeAll()
        currentPath = FileSystemService.shared.playgroundPath
    }
}

// MARK: - Preview

#Preview {
    ChaoticFinderView()
        .frame(width: 800, height: 700)
}
