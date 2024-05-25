import SwiftUI

struct ArtworkSquare : View {
    let image : Image
    
    var contentMode     : ContentMode = .fill
    var size            : Double      = UIConfig.SquareSizes.huge
    var font            : Font        = .title
    var backgroundColor : Color       = Color(.systemGray5) 
    var cornerRadius    : Double      = UIConfig.CornerRadiuses.mini
    var bottomPadding   : Double      = UIConfig.Paddings.mini
    
    init ( 
        _ i : Image, 
        contentMode     : ContentMode = .fill, 
        size            : Double      = UIConfig.SquareSizes.huge,
        font            : Font        = .title,
        backgroundColor : Color       = Color(.systemGray5) ,
        cornerRadius    : Double      = UIConfig.CornerRadiuses.mini,
        bottomPadding   : Double      = UIConfig.Paddings.mini
    ) {
        self.image = i
        self.contentMode     = contentMode
        self.size            = size
        self.font            = font
        self.backgroundColor = backgroundColor
        self.cornerRadius    = cornerRadius
        self.bottomPadding   = bottomPadding
    }
    
    var body : some View {
        image
            .aspectRatio ( contentMode: contentMode )
            .font ( font )
            .frame (
                width: size,
                height: size
            )
            .background( backgroundColor )
            .clipShape (
                RoundedRectangle (
                    cornerRadius: cornerRadius
                )
            )
            .padding(.bottom, bottomPadding)
    }
    
}

#Preview {
    ArtworkSquare(
        Image(systemName: "music.note")
    )
}
