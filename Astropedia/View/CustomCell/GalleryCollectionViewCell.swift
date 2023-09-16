//
//  GalleryCollectionViewCell.swift
//  Astropedia
//
//  Created by Yves Charpentier on 10/06/2023.
//

import UIKit
import SDWebImage

class GalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    func configure(image: String) {
        imageView.sd_setImage(with: URL(string: image))
    }
}
