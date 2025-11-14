import Foundation

struct FileItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let path: URL
    let size: Int64
    let isDirectory: Bool
    let creationDate: Date
    var displayName: String  // Can differ from actual name for chaos

    init(url: URL) {
        self.id = UUID()
        self.path = url
        self.name = url.lastPathComponent

        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        self.size = attributes?[.size] as? Int64 ?? 0
        self.creationDate = attributes?[.creationDate] as? Date ?? Date()

        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        self.isDirectory = isDir.boolValue

        self.displayName = url.lastPathComponent
    }

    var sizeString: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    var icon: String {
        if isDirectory {
            return "folder.fill"
        }

        let ext = path.pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.fill"
        case "jpg", "jpeg", "png", "gif": return "photo.fill"
        case "mp4", "mov": return "film.fill"
        case "mp3", "wav": return "music.note"
        case "zip": return "doc.zipper"
        case "txt": return "doc.text.fill"
        case "swift": return "chevron.left.forwardslash.chevron.right"
        default: return "doc.fill"
        }
    }
}
