import SwiftUI

// MARK: - File System Service

class FileSystemService: ObservableObject {
    static let shared = FileSystemService()

    let playgroundPath: URL
    let trashPath: URL

    init() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        self.playgroundPath = homeDir.appendingPathComponent("Documents/ChaoticPlayground")
        self.trashPath = homeDir.appendingPathComponent(".ChaoticTrash")

        setupDirectories()
    }

    func setupDirectories() {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: playgroundPath.path) {
            try? fileManager.createDirectory(at: playgroundPath, withIntermediateDirectories: true)
            createInitialStructure()
        }

        if !fileManager.fileExists(atPath: trashPath.path) {
            try? fileManager.createDirectory(at: trashPath, withIntermediateDirectories: true)
        }
    }

    private func createInitialStructure() {
        let fileManager = FileManager.default

        let folders = ["Work", "Personal", "Photos", "Music", "Random"]
        for folderName in folders {
            let folderPath = playgroundPath.appendingPathComponent(folderName)
            try? fileManager.createDirectory(at: folderPath, withIntermediateDirectories: true)
        }

        let rootFiles = [
            "important_document.txt": "This is a very important document.",
            "vacation_photo.jpg": "Photo data",
            "project_final_v3.docx": "Final version... maybe.",
            "budget_2024.xlsx": "Budget spreadsheet",
            "presentation.pdf": "Presentation slides"
        ]

        for (fileName, content) in rootFiles {
            let filePath = playgroundPath.appendingPathComponent(fileName)
            try? content.write(to: filePath, atomically: true, encoding: .utf8)
        }

        let workPath = playgroundPath.appendingPathComponent("Work")
        let workFiles = [
            "meeting_notes.txt": "Meeting notes from today",
            "report_q4.docx": "Q4 report",
            "client_data.xlsx": "Client information"
        ]

        for (fileName, content) in workFiles {
            let filePath = workPath.appendingPathComponent(fileName)
            try? content.write(to: filePath, atomically: true, encoding: .utf8)
        }
    }

    func loadFiles(at path: URL) -> [FileItem] {
        let fileManager = FileManager.default

        guard let contents = try? fileManager.contentsOfDirectory(
            at: path,
            includingPropertiesForKeys: [.fileSizeKey, .creationDateKey, .isDirectoryKey]
        ) else {
            return []
        }

        return contents
            .filter { !$0.lastPathComponent.hasPrefix(".") }
            .map { FileItem(url: $0) }
    }
}

// MARK: - Shuffle Manager

enum ShuffleType: String, CaseIterable {
    case random = "Random Chaos"
    case reverseAlpha = "Z→A"
    case sizeSort = "Tiny First"
    case extensionChaos = "Extension Madness"
    case dateChaos = "Time Traveler"

    var emoji: String {
        switch self {
        case .random: return "🎲"
        case .reverseAlpha: return "🔄"
        case .sizeSort: return "📏"
        case .extensionChaos: return "🎨"
        case .dateChaos: return "⏰"
        }
    }
}

class ShuffleManager: ObservableObject {
    @Published var currentShuffleType: ShuffleType?
    @Published var shuffleCount: Int = 0
    @Published var todayShuffleCount: Int = 0

    func shuffleFolder(_ items: [FileItem]) -> [FileItem] {
        let shuffleType = ShuffleType.allCases.randomElement()!
        return shuffleFolder(items, with: shuffleType)
    }

    func shuffleFolder(_ items: [FileItem], with type: ShuffleType) -> [FileItem] {
        let shuffled = applyShuffleAlgorithm(items, type: type)

        currentShuffleType = type
        shuffleCount += 1
        todayShuffleCount += 1

        return shuffled
    }

    private func applyShuffleAlgorithm(_ items: [FileItem], type: ShuffleType) -> [FileItem] {
        switch type {
        case .random:
            return items.shuffled()
        case .reverseAlpha:
            return items.sorted { $0.name.lowercased() > $1.name.lowercased() }
        case .sizeSort:
            return items.sorted { $0.size < $1.size }
        case .extensionChaos:
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
        case .dateChaos:
            return items.sorted { $0.creationDate < $1.creationDate }
        }
    }
}

// MARK: - Main View

struct ChaoticFilePickerView: View {
    @StateObject private var fileService = FileSystemService.shared
    @StateObject private var shuffleManager = ShuffleManager()

    @State private var currentPath: URL
    @State private var navigationStack: [URL] = []
    @State private var selectedFile: FileItem?
    @State private var showWheel = false
    @State private var shuffledItems: [FileItem] = []
    @State private var isShuffling = false

    init() {
        let path = FileSystemService.shared.playgroundPath
        _currentPath = State(initialValue: path)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            let items = fileService.loadFiles(at: currentPath)

            if items.isEmpty {
                emptyStateView
            } else {
                fileListView(items: items)
            }
        }
        .frame(width: 700, height: 600)
        .sheet(isPresented: $showWheel) {
            if let file = selectedFile {
                WheelOfDoomView(file: file)
            }
        }
        .onAppear {
            performInitialShuffle()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.blue)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Chaotic Finder")
                        .font(.title.bold())

                    Text(currentPath.lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if !navigationStack.isEmpty {
                    Button(action: navigateBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                    .buttonStyle(.bordered)
                }

                Button(action: resetToRoot) {
                    Image(systemName: "house.fill")
                }
                .buttonStyle(.bordered)
            }

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
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }

    // MARK: - File List

    private func fileListView(items: [FileItem]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                let displayItems = shuffledItems.isEmpty ? items : shuffledItems

                ForEach(Array(displayItems.enumerated()), id: \.element.id) { index, item in
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

            if !navigationStack.isEmpty {
                Button(action: navigateBack) {
                    Text("Go Back")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func performInitialShuffle() {
        let items = fileService.loadFiles(at: currentPath)
        guard !items.isEmpty else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            performShuffle()
        }
    }

    private func performShuffle() {
        let items = fileService.loadFiles(at: currentPath)
        guard !items.isEmpty && !isShuffling else { return }

        isShuffling = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                shuffledItems = shuffleManager.shuffleFolder(items)
            }

            isShuffling = false
        }
    }

    private func handleItemTap(_ item: FileItem) {
        if item.isDirectory {
            navigateToFolder(item)
        } else {
            selectedFile = item
            showWheel = true
        }
    }

    private func navigateToFolder(_ folder: FileItem) {
        navigationStack.append(currentPath)
        currentPath = folder.path
        shuffledItems = []
        performInitialShuffle()
    }

    private func navigateBack() {
        guard let previous = navigationStack.popLast() else { return }
        currentPath = previous
        shuffledItems = []
        performInitialShuffle()
    }

    private func resetToRoot() {
        navigationStack.removeAll()
        currentPath = FileSystemService.shared.playgroundPath
        shuffledItems = []
        performInitialShuffle()
    }
}

// MARK: - File Row View

struct FileRowView: View {
    let item: FileItem
    let index: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("\(index)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)

            Image(systemName: item.icon)
                .foregroundColor(item.isDirectory ? .blue : .gray)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)

                Text(item.isDirectory ? "Folder" : item.sizeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: item.isDirectory ? "chevron.right" : "flame.fill")
                .font(.caption)
                .foregroundColor(item.isDirectory ? .secondary : .orange)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(6)
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}

// MARK: - Legacy FilePickerView (for compatibility)

struct FilePickerView: View {
    var body: some View {
        ChaoticFilePickerView()
    }
}

#Preview {
    ChaoticFilePickerView()
}
