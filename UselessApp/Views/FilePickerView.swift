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
        let fileManager = FileManager.default

        let folders = [
            "Work Documents",
            "Personal",
            "Projects",
            "Photos",
            "Downloads",
            "Tax Stuff",
            "Old Files"
        ]

        for folder in folders {
            let folderPath = currentPath.appendingPathComponent(folder)
            try? fileManager.createDirectory(at: folderPath, withIntermediateDirectories: true)
        }

        createWorkDocuments()
        createPersonalFiles()
        createProjects()
        createPhotos()
        createDownloads()
        createTaxFiles()
        createOldFiles()
        createRootFiles()
    }

    func createWorkDocuments() {
        let workPath = currentPath.appendingPathComponent("Work Documents")
        let files = [
            "Q4_Report_FINAL.docx",
            "Q4_Report_FINAL_v2.docx",
            "Q4_Report_FINAL_FINAL.docx",
            "Q4_Report_ACTUALLY_FINAL.docx",
            "Meeting_Notes_2024.txt",
            "Budget_Proposal.xlsx",
            "Client_Presentation.pptx",
            "Performance_Review_Draft.pdf",
            "Untitled.docx",
            "DO_NOT_DELETE.txt"
        ]

        for file in files {
            createFile(at: workPath.appendingPathComponent(file), size: 15000)
        }

        let subfolderPath = workPath.appendingPathComponent("Archive")
        try? FileManager.default.createDirectory(at: subfolderPath, withIntermediateDirectories: true)
        createFile(at: subfolderPath.appendingPathComponent("old_project.zip"), size: 250000)
    }

    func createPersonalFiles() {
        let personalPath = currentPath.appendingPathComponent("Personal")
        let files = [
            "TODO.txt",
            "passwords_DO_NOT_SHARE.txt",
            "diary_2024.txt",
            "book_recommendations.txt",
            "recipe_moms_lasagna.pdf",
            "gym_membership_card.jpg",
            "insurance_documents.pdf"
        ]

        for file in files {
            createFile(at: personalPath.appendingPathComponent(file), size: 8000)
        }
    }

    func createProjects() {
        let projectsPath = currentPath.appendingPathComponent("Projects")

        let projectFolders = ["Website Redesign", "App Idea", "Abandoned", "Maybe Someday"]
        for folder in projectFolders {
            let folderPath = projectsPath.appendingPathComponent(folder)
            try? FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true)
        }

        let websitePath = projectsPath.appendingPathComponent("Website Redesign")
        createFile(at: websitePath.appendingPathComponent("index.html"), size: 5000)
        createFile(at: websitePath.appendingPathComponent("styles.css"), size: 3000)
        createFile(at: websitePath.appendingPathComponent("script.js"), size: 7000)
        createFile(at: websitePath.appendingPathComponent("mockup_v1.png"), size: 180000)

        let appPath = projectsPath.appendingPathComponent("App Idea")
        createFile(at: appPath.appendingPathComponent("pitch.txt"), size: 2000)
        createFile(at: appPath.appendingPathComponent("wireframes.pdf"), size: 95000)

        let abandonedPath = projectsPath.appendingPathComponent("Abandoned")
        createFile(at: abandonedPath.appendingPathComponent("project_that_was_gonna_be_big.zip"), size: 500000)
        createFile(at: abandonedPath.appendingPathComponent("why_this_failed.txt"), size: 1500)
    }

    func createPhotos() {
        let photosPath = currentPath.appendingPathComponent("Photos")
        let years = ["2022", "2023", "2024"]

        for year in years {
            let yearPath = photosPath.appendingPathComponent(year)
            try? FileManager.default.createDirectory(at: yearPath, withIntermediateDirectories: true)
        }

        let photos2024 = photosPath.appendingPathComponent("2024")
        let photoFiles = [
            "IMG_0001.jpg",
            "IMG_0002.jpg",
            "IMG_0003_blurry.jpg",
            "IMG_0004.jpg",
            "vacation_beach.jpg",
            "vacation_beach (1).jpg",
            "screenshot_2024_11_14.png",
            "meme_i_downloaded.jpg",
            "cat_photo_cute.jpg"
        ]

        for photo in photoFiles {
            createFile(at: photos2024.appendingPathComponent(photo), size: 1200000)
        }
    }

    func createDownloads() {
        let downloadsPath = currentPath.appendingPathComponent("Downloads")
        let files = [
            "invoice_march.pdf",
            "setup_installer.dmg",
            "random_article.pdf",
            "screenshot_2024_10_12.png",
            "Untitled.png",
            "zoom_recording.mp4",
            "document (1).pdf",
            "document (2).pdf",
            "document (3).pdf",
            "file.zip",
            "downloaded_template.xlsx"
        ]

        for file in files {
            let size = file.hasSuffix(".mp4") ? 25000000 : (file.hasSuffix(".dmg") ? 85000000 : 45000)
            createFile(at: downloadsPath.appendingPathComponent(file), size: size)
        }
    }

    func createTaxFiles() {
        let taxPath = currentPath.appendingPathComponent("Tax Stuff")
        let files = [
            "tax_return_2023.pdf",
            "receipts_2023.xlsx",
            "receipts_2024.xlsx",
            "important_tax_document.pdf",
            "do_not_lose_this.pdf",
            "deductions.txt"
        ]

        for file in files {
            createFile(at: taxPath.appendingPathComponent(file), size: 35000)
        }
    }

    func createOldFiles() {
        let oldPath = currentPath.appendingPathComponent("Old Files")
        let files = [
            "thesis_2015.docx",
            "college_notes.zip",
            "my_first_website.html",
            "cringe_poetry.txt",
            "MySpace_backup.zip",
            "AOL_emails.txt",
            "high_school_essay.doc"
        ]

        for file in files {
            createFile(at: oldPath.appendingPathComponent(file), size: 25000)
        }
    }

    func createRootFiles() {
        let rootFiles = [
            "README.txt",
            "notes.txt",
            "temporary_file.tmp",
            "config.json",
            "backup_before_disaster.zip",
            "this_is_fine.jpg",
            "definitely_not_suspicious.exe"
        ]

        for file in rootFiles {
            createFile(at: currentPath.appendingPathComponent(file), size: 12000)
        }
    }

    func createFile(at path: URL, size: Int) {
        let content = String(repeating: "X", count: size)
        try? content.write(to: path, atomically: true, encoding: .utf8)
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
    @State private var mouseLocation: CGPoint = .zero
    @State private var isHovering = false
    @State private var offset: CGSize = .zero

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
        .offset(offset)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: offset)
        .background(GeometryReader { geometry in
            Color.clear.onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    isHovering = true
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    let dx = location.x - center.x
                    let dy = location.y - center.y

                    let distance = sqrt(dx * dx + dy * dy)
                    let maxDistance: CGFloat = 100

                    if distance < maxDistance && !file.isDirectory {
                        let pushStrength: CGFloat = 30
                        let normalizedDx = dx / max(distance, 1)
                        let normalizedDy = dy / max(distance, 1)

                        offset = CGSize(
                            width: -normalizedDx * pushStrength,
                            height: -normalizedDy * pushStrength
                        )
                    }
                case .ended:
                    isHovering = false
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        offset = .zero
                    }
                }
            }
        })
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
