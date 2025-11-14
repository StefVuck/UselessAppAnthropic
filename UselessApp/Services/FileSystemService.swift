//
//  FileSystemService.swift
//  UselessApp
//
//  Created by Claude on 2025-11-14.
//

import Foundation

class FileSystemService: ObservableObject {
    static let shared = FileSystemService()

    let playgroundPath: URL
    let trashPath: URL

    private var operationManifest: [FileOperation] = []

    init() {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        self.playgroundPath = homeDir.appendingPathComponent("Documents/ChaoticPlayground")
        self.trashPath = homeDir.appendingPathComponent(".ChaoticTrash")

        setupDirectories()
    }

    // MARK: - Setup

    func setupDirectories() {
        let fileManager = FileManager.default

        // Create playground directory
        if !fileManager.fileExists(atPath: playgroundPath.path) {
            try? fileManager.createDirectory(at: playgroundPath,
                                            withIntermediateDirectories: true)
            createInitialStructure()
        }

        // Create trash directory
        if !fileManager.fileExists(atPath: trashPath.path) {
            try? fileManager.createDirectory(at: trashPath,
                                            withIntermediateDirectories: true)
        }
    }

    private func createInitialStructure() {
        let fileManager = FileManager.default

        // Create sample folders
        let folders = ["Work", "Personal", "Photos", "Music", "Random"]
        for folderName in folders {
            let folderPath = playgroundPath.appendingPathComponent(folderName)
            try? fileManager.createDirectory(at: folderPath,
                                            withIntermediateDirectories: true)
        }

        // Create sample files in root
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

        // Create files in Work folder
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

        // Create files in Personal folder
        let personalPath = playgroundPath.appendingPathComponent("Personal")
        let personalFiles = [
            "diary.txt": "My personal diary",
            "todo_list.txt": "Things to do",
            "passwords.txt": "Just kidding, don't store passwords here!"
        ]

        for (fileName, content) in personalFiles {
            let filePath = personalPath.appendingPathComponent(fileName)
            try? content.write(to: filePath, atomically: true, encoding: .utf8)
        }
    }

    // MARK: - File Operations

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

    func openFile(_ file: FileItem) {
        NSWorkspace.shared.open(file.path)
    }

    func teleportFile(_ file: FileItem) -> URL? {
        guard isInSandbox(file.path) else { return nil }

        let fileManager = FileManager.default

        // Find a random folder in the playground
        guard let randomFolder = findRandomFolder() else { return nil }

        let newPath = randomFolder.appendingPathComponent(file.name)

        do {
            try fileManager.moveItem(at: file.path, to: newPath)

            // Leave a breadcrumb file
            let breadcrumb = file.path.appendingPathComponent(".breadcrumb_\(file.name).txt")
            let breadcrumbContent = "File '\(file.name)' was teleported to: \(newPath.path)"
            try? breadcrumbContent.write(to: breadcrumb, atomically: true, encoding: .utf8)

            // Log operation
            logOperation(.teleport(from: file.path, to: newPath))

            return newPath
        } catch {
            print("Failed to teleport file: \(error)")
            return nil
        }
    }

    func deleteFile(_ file: FileItem) -> Bool {
        guard isInSandbox(file.path) else { return false }

        let fileManager = FileManager.default
        let trashDestination = trashPath.appendingPathComponent(file.name)

        do {
            // Move to trash instead of deleting
            if fileManager.fileExists(atPath: trashDestination.path) {
                // Add timestamp if file already exists in trash
                let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
                let newName = "\(file.path.deletingPathExtension().lastPathComponent)_\(timestamp).\(file.path.pathExtension)"
                let uniqueTrash = trashPath.appendingPathComponent(newName)
                try fileManager.moveItem(at: file.path, to: uniqueTrash)
            } else {
                try fileManager.moveItem(at: file.path, to: trashDestination)
            }

            // Log operation
            logOperation(.delete(from: file.path, to: trashDestination))

            return true
        } catch {
            print("Failed to delete file: \(error)")
            return false
        }
    }

    // MARK: - Safety Checks

    func isInSandbox(_ path: URL) -> Bool {
        return path.path.hasPrefix(playgroundPath.path)
    }

    // MARK: - Helpers

    private func findRandomFolder() -> URL? {
        let fileManager = FileManager.default

        guard let contents = try? fileManager.contentsOfDirectory(
            at: playgroundPath,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }

        let folders = contents.filter { url in
            var isDir: ObjCBool = false
            fileManager.fileExists(atPath: url.path, isDirectory: &isDir)
            return isDir.boolValue
        }

        return folders.randomElement() ?? playgroundPath
    }

    private func logOperation(_ operation: FileOperation) {
        operationManifest.append(operation)
        // In a real app, we'd persist this to disk
    }

    // MARK: - Manifest

    func getOperationHistory() -> [FileOperation] {
        return operationManifest
    }

    func clearHistory() {
        operationManifest.removeAll()
    }
}

// MARK: - Supporting Types

enum FileOperation {
    case teleport(from: URL, to: URL)
    case delete(from: URL, to: URL)

    var description: String {
        switch self {
        case .teleport(let from, let to):
            return "Teleported '\(from.lastPathComponent)' to \(to.deletingLastPathComponent().lastPathComponent)"
        case .delete(let from, let to):
            return "Deleted '\(from.lastPathComponent)' (recoverable from trash)"
        }
    }

    var date: Date {
        return Date()
    }
}
