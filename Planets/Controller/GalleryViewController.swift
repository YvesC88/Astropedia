//
//  GalleryCollectionViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 10/06/2023.
//

import UIKit

class GalleryViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var solarSystem: SolarSystem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        solarSystem.galleries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GalleryCollectionViewCell
        
        let item = solarSystem.galleries[indexPath.row]
        cell.configure(image: item)
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = solarSystem.galleries[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailGalleryVC = storyboard.instantiateViewController(withIdentifier: "DetailGalleryViewController") as? DetailGalleryViewController else { return }
        detailGalleryVC.image = selectedImage
        self.present(detailGalleryVC, animated: true)
//        self.navigationController?.pushViewController(detailGalleryVC, animated: true)
    }
}
