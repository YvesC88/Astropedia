//
//  GalleryCollectionViewCell.swift
//  Astropedia
//
//  Created by Yves Charpentier on 10/06/2023.
//

import UIKit
import SDWebImage

final class GalleryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    // Tres important de ne pas oublier de clean ta cell car tu download une image, qui peut prendre un certain temps
    // Ca t'evitera les bugs/effets de blinks d'image dans tes cells si tu scroll vite
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
    }

    func configure(image: String) {
        imageView.sd_setImage(with: URL(string: image))
    }
}
