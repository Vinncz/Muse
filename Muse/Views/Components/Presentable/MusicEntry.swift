import SwiftUI

struct MusicEntry: View {

/// Artwork to be displayed. Wrap your instance of `ArtworkSquare` inside an `AnyView`, then pass it here to be shown. 
///  
/// ## Usage
/// ```swift
/// MusicEntry (
///     artwork : AnyView (
///         ArtworkSquare ( 
///             Image( systemName: "music.note" ),
///             size : UIConfigs.SquareSizes.giant,
///             font : .largeTitle
///         )
///     ),
///     title   : "Hello, world!",
///     desc    : "Kizuna Ai"
/// )
///   ```
    let artwork            : AnyView
/// Title for the entry; which is shown on bold, always positioned above `desc`, and below `artwork`.
    let title              : String
/// Description for the entry; which is smaller than `title`. It is the bottom-most element inside a `MusicEntry`.
    let desc               : String
/// Responsible for text wrapping; if you set this to infinity, any text passed into either `title` or `desc` will be shown in its full length.
    var width              : Double = UIConfigs.SquareSizes.huge
/// Responsible for the spacing between `title` and `desc`.
    var spacing            : Double = UIConfigs.Spacings.normal
/// Alignment for the `VStack` which wraps your `artwork`, `title`, and `desc`. It is NOT responsible for text alignment.
    var alignment          : HorizontalAlignment = .leading
/// Alignment of the text for your `title`, and `desc`. It is NOT responsible for `VStack` alignment.
    var multiLineAlignment : TextAlignment = .leading
/// Font variant which affects your `title`. Usually used to modify how large a `title` will be shown as. 
    var titleFont          : Font = .headline
/// Font variant which affects your `desc`. Usually used to modify how large a `desc` will be shown as. 
    var descFont           : Font = .body
/// Responsible for setting up the maximum number of line for both `title` and `desc`.
    var lineLimit          : Int = 2
    
    var body: some View {
        VStack ( alignment: alignment, spacing: spacing ) {
            artwork
                    
            Text( title )
                .font( titleFont )
                .multilineTextAlignment(multiLineAlignment)
                .lineLimit(lineLimit)
                .bold()
            
            Text( desc )
                .font( descFont )
                .multilineTextAlignment(multiLineAlignment)
                .lineLimit(lineLimit)
                .opacity( 0.5 )
        }
            .frame(
                width: width
            )
            .padding()
    }
}

#Preview {
    MusicEntry (
        artwork   : AnyView(
            ArtworkSquare( 
                Image(systemName: "music.note")
                ,size: UIConfigs.SquareSizes.giant
                ,font: .largeTitle
            )
        ), 
        title     : "Import music", 
        desc      : "After importing, Muse will be able to play them",
        width     : UIConfigs.SquareSizes.giant,
        alignment : .center,
        multiLineAlignment: .center,
        titleFont : .title,
        descFont  : .title3
    )
}

/*
 VStack ( alignment: .leading ) {
     Button { pickerIsShown = true } label: { 
         ArtworkSquare( Image(systemName: "plus.circle") )
     }
             
     Text( "Import music" )
         .font( .headline )
         .lineLimit(2)
         .bold()
     
     Text( "After importing, Muse will be able to play it" )
         .font( .body )
         .opacity( 0.5 )
         .lineLimit(2)
 }
     .frame(
         width: UIConfigs.SquareSizes.huge
     )
     .padding()
 */
