//
//  PictureViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 23/04/2023.
//

import Foundation
import UIKit

class PictureViewController: UIViewController {
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explanationTextView: UITextView!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var definitionButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private let pictureService = PictureService()
    let refreshControl = UIRefreshControl()
    private var isHD = false
    private var picture: Picture!
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definitionButton.isSelected = false
        activityIndicatorView.center = self.view.center
        activityIndicatorView.color = UIColor.white
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
        fetchPicture()
        setRefreshControl()
    }
    
    func setRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshImageView), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
    @objc func refreshImageView() {
        fetchPicture()
        if let sdUrl = UserDefaults.standard.string(forKey: "savedSDUrl") {
            fetchImage(url: sdUrl)
        } else {
            self.presentAlert(title: "Erreur", message: "Erreur réseau")
        }
        refreshControl.endRefreshing()
    }
    
    private func fetchPicture() {
        activityIndicatorView.startAnimating()
        imageView.isHidden = true
        pictureService.getPicture() { picture in
            if let picture = picture {
                self.picture = picture.toPicture()
                UserDefaults.standard.set(self.picture.url, forKey: "savedSDUrl")
                UserDefaults.standard.set(self.picture.hdurl, forKey: "savedHDUrl")
                self.titleLabel.text = self.picture.title
                self.explanationTextView.text = self.picture.explanation
                if let copyright = self.picture.copyright {
                    self.copyrightLabel.text = copyright
                } else {
                    self.copyrightLabel.text = "Pas d'auteur"
                }
                self.fetchImage(url: (self.picture.url!))
            } else {
                self.presentAlert(title: "Erreur", message: "Erreur réseau.")
            }
        }
    }
    
    private func fetchImage(url: String) {
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: imageData)
                    self.imageView.isHidden = false
                    self.activityIndicatorView.stopAnimating()
                }
            }
            .resume()
        }
    }
    
    @IBAction func openLink(_ sender: UIButton) {
        if isHD {
            if let hdUrl = UserDefaults.standard.string(forKey: "savedHDUrl") {
                UIApplication.shared.open(URL(string: hdUrl)!)
            }
        } else {
            if let sdUrl = UserDefaults.standard.string(forKey: "savedSDUrl") {
                UIApplication.shared.open(URL(string: sdUrl)!)
            }
        }
    }
    
    @IBAction func hdButtonTapped(_ sender: UIButton) {
        if isHD {
            if let sdUrl = UserDefaults.standard.string(forKey: "savedSDUrl") {
                fetchImage(url: sdUrl)
            }
            isHD = false
            definitionButton.setTitle("En version HD", for: .normal)
        } else {
            if let hdUrl = UserDefaults.standard.string(forKey: "savedHDUrl") {
                fetchImage(url: hdUrl)
            }
            isHD = true
            definitionButton.setTitle("En version SD", for: .normal)
        }
    }
    
    @IBAction func didSaveImage() {
        if picture == nil {
            self.presentAlert(title: "Patientez", message: "Chargement en cours...")
        } else {
            guard let image = self.imageView.image else { return }
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func getFavorite() {
        if picture == nil {
            self.presentAlert(title: "Patientez", message: "Chargment en cours...")
        } else {
            let imageData = (try? Data(contentsOf: URL(string: picture.url!)!))!
            let imageKey = pictureService.createImageKey(imageData: imageData)
            pictureService.savePicture(title: picture.title,
                                       url: picture.url,
                                       hdurl: picture.hdurl,
                                       copyright: picture.copyright,
                                       explanation: picture.explanation,
                                       imageKey: imageKey)
        }
    }
}
