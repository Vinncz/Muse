import SwiftUI

struct MusicPicker: UIViewControllerRepresentable {
    @Binding var selectedFiles: [MusicFile]
    @Binding var pickerIsShown: Bool
    @Binding var pickerIsDone_SoShowConfirmation : Bool
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [
                .mp3, 
                    .wav, 
                    .appleProtectedMPEG4Audio, 
                    .audio, 
                    .midi
            ]
        )
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = true
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: MusicPicker
        
        init(_ parent: MusicPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedFiles = urls.compactMap { url in
                guard url.startAccessingSecurityScopedResource() else { return nil }
                defer { 
                    url.stopAccessingSecurityScopedResource()
                    self.parent.pickerIsShown = false
                    self.parent.pickerIsDone_SoShowConfirmation = true
                    
                    parent.selectedFiles.append(contentsOf: [])
                }
                
                do {
                    let resources = try url.resourceValues(forKeys: [.fileSizeKey])
                    
                    var bookmarkObject : Data
                    do {
                        bookmarkObject = try url.bookmarkData()
                    } catch let error {
                        Logger.log("Failed to create bookmark: \(error)")
                        return nil
                    }
                    
                    let components = url.lastPathComponent.split(separator: ",", maxSplits: 1)
                    let title = String(components[0])
                    
                    let backwardString = String(components[1].reversed())
                    let fileFormatOmmited = backwardString.split(separator: ".", maxSplits: 1)
                    let artists = String(fileFormatOmmited[1].reversed().dropFirst(1))
                                        
                    let size = resources.fileSize ?? 0
                    let type = url.pathExtension
                    
                    return MusicFile (
                        url: url, 
                        bookmark: bookmarkObject,
                        title: title,
                        artists: artists, 
                        type: type, 
                        size: size
                    )
                    
                } catch {
                    print("Error in importing file \(error)")
                    return nil
                    
                }
            }
        }
    }
}
