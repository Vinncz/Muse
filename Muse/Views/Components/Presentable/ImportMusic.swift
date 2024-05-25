import SwiftUI

struct ImportMusic: View {
    @Environment(\.modelContext) private var modelContext
    
    @State var selectedFiles                    : [MusicFile] = []
    @State var pickerIsShown                    : Bool        = false
    @State var pickerIsDone_SoShowConfirmation  : Bool        = false
    
    var body: some View {
        Button { pickerIsShown = true } label: { 
            MusicEntry (
                artwork   : AnyView (
                    ArtworkSquare( Image(systemName: "plus.circle") )
                ), 
                title     : "Import music", 
                desc      : "Importing will enable Muse to play said music",
                lineLimit : 3
            )
        }
            .buttonStyle(PlainButtonStyle()) 
        
        /* FilePicker Sheet */
        .sheet( isPresented: $pickerIsShown ) { 
                MusicPicker ( 
                    selectedFiles: $selectedFiles, 
                    pickerIsShown: $pickerIsShown, 
                    pickerIsDone_SoShowConfirmation: $pickerIsDone_SoShowConfirmation 
                ) 
            }
        
        /* Import Confirmation Sheet */
        .sheet( isPresented: $pickerIsDone_SoShowConfirmation ) {
                ImportConfirmationSheet
            }
        
        /* Button shortcut for importing files */
        .toolbar {
                Button { pickerIsShown = true } label: { Image(systemName: "plus.circle") }
            }
    }
    
    /* File-specific helper functions */
    fileprivate func insertToSwiftData ( ) {        
        selectedFiles.forEach { file in
            let title = file.title
            let artists = file.artists
            let pathToFile = file.url
            let bookmark = file.bookmark
            let attempts : [Attempt] = []
            
            let song = Music (
                _title: title, 
                _artists: artists,
                _attempts: attempts, 
                _url: pathToFile,
                _bookmark: bookmark
            )
            
            print(song.title)
            print(song.artists)
            print(song.attempts)
            print(song.url)
            print(file.size)
            print(file.bookmark)
            
            modelContext.insert(song)
            selectedFiles.removeAll {
                $0.id == file.id
            }
        }        
    }
    
    
    
    /* Start of File-specific Components area */
        var ImportConfirmationSheet : some View {
            HStack {
                VStack ( alignment: .leading ) {
                    Text("Do you wish to import")
                        .font( .largeTitle )
                        .bold()
                        .padding( UIConfig.Paddings.normal )
                        .padding( .top, 32 )
                    ListOfSelectedFiles
                    Spacer()
                    ConfirmationArea
                }
                    .padding()
                Spacer()
            }
        }
    
        var ListOfSelectedFiles : some View {
            HStack {
                ScrollView {
                    VStack ( alignment: .leading, spacing: UIConfig.Spacings.normal ) {
                        ForEach ( selectedFiles ) { file in
                            HStack ( spacing: UIConfig.CornerRadiuses.normal ) {
                                Image(systemName: "music.note")
                                    .padding()
                                Text( "\(file.title), \(file.artists)" )
                                Spacer()
                            }
                                .padding( .all, UIConfig.Paddings.mini )
                                .background( Color(.systemGray5) )
                                .clipShape(RoundedRectangle(cornerRadius: UIConfig.CornerRadiuses.micro))
                        }
                        Spacer()
                    }
                        .padding()
                }
            }
        }
        
        var ConfirmationArea : some View {
            HStack {
                Spacer()
                VStack ( spacing: UIConfig.Spacings.huge - UIConfig.Spacings.mini ) {
                    ConfirmationButton
                    CancelButton
                }
                    .padding()
                Spacer()
            }
        }
        
        var ConfirmationButton : some View {
            return Button {
                insertToSwiftData() 
                pickerIsDone_SoShowConfirmation = false
            } label: {
                Spacer()
                Text("Yes, import")
                    .padding(.all, UIConfig.Paddings.normal)
                Spacer()
            }
                .bold()
                .buttonStyle(.borderedProminent)
        }
        
        var CancelButton : some View {
            return Button {
                pickerIsDone_SoShowConfirmation = false
            } label: {
                Spacer()
                Text("No, I did an oopsie")
                    .padding(.all, UIConfig.Paddings.mini)
                Spacer()
            }
                .bold()
        }
    /* End of File-specific Components area */
}

#Preview {
    ImportMusic()
}
