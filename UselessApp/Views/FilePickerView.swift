import SwiftUI

struct FilePickerView: View {
    @State private var currentPath: URL
    @State private var files: [FileItem] = []
    @State private var selectedFile: FileItem?
    @State private var showWheel = false

    init() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let playgroundDir = homeDir.appendingPathComponent("Documents/ChaoticPlayground")
        _currentPath = State(initialValue: playgroundDir)
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(currentPath: currentPath)

            if files.isEmpty {
                EmptyStateView()
            } else {
                List(files) { file in
                    FileRow(file: file)
                        .onTapGesture {
                            handleFileTap(file)
                        }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            setupPlayground()
            loadFiles()
        }
        .sheet(item: $selectedFile) { file in
            WheelOfDoomView(file: file)
        }
    }

    func setupPlayground() {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: currentPath.path) {
            try? fileManager.createDirectory(at: currentPath,
                                            withIntermediateDirectories: true)

            createSampleFiles()
        }
    }

    func createSampleFiles() {
        let sampleFiles = [
            "important_document.txt",
            "vacation_photo.jpg",
            "project_final.docx",
            "budget_2024.xlsx",
            "presentation.pdf"
        ]

        for fileName in sampleFiles {
            let filePath = currentPath.appendingPathComponent(fileName)
            let content = "This is a sample file: \(fileName)"
            try? content.write(to: filePath, atomically: true, encoding: .utf8)
        }

        let subfolderPath = currentPath.appendingPathComponent("MyFolder")
        try? FileManager.default.createDirectory(at: subfolderPath,
                                                 withIntermediateDirectories: true)
    }

    func loadFiles() {
        let fileManager = FileManager.default

        guard let contents = try? fileManager.contentsOfDirectory(at: currentPath,
                                                                  includingPropertiesForKeys: nil)
        else {
            files = []
            return
        }

        files = contents
            .filter { !$0.lastPathComponent.hasPrefix(".") }
            .map { FileItem(url: $0) }
            .sorted { $0.name < $1.name }
    }

    func handleFileTap(_ file: FileItem) {
        if file.isDirectory {
            currentPath = file.path
            loadFiles()
        } else {
            selectedFile = file
            showWheel = true
        }
    }
}

struct HeaderView: View {
    let currentPath: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Chaotic File Browser")
                .font(.largeTitle.bold())

            Text("Choose a file to spin the Wheel of Doom")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.blue)
                Text(currentPath.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(.top, 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct FileRow: View {
    let file: FileItem

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: file.icon)
                .font(.title2)
                .foregroundColor(file.isDirectory ? .blue : .primary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.body)

                if !file.isDirectory {
                    Text(file.sizeString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if !file.isDirectory {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No files found")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("Add some files to ~/Documents/ChaoticPlayground")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FilePickerView()
}
