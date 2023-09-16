//
//  DetailGalleryViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 10/06/2023.
//

import Foundation
import UIKit
import SDWebImage

class DetailGalleryViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showImage(image: image)
    }
    
    func showImage(image: String) {
        imageView.sd_setImage(with: URL(string: image))
    }
    
    @IBAction func dismissDetailGalleryVC() {
        dismiss(animated: true)
    }
    
    @IBAction func shareImage() {
        guard let image = imageView.image else { return }
        shareItems([image])
    }
}