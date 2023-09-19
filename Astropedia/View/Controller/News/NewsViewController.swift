//
//  NewsViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit
import Combine

class NewsViewController: UIViewController {
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var pictureTableView: UITableView!
    @IBOutlet weak private var articleTableView: UITableView!
    @IBOutlet weak private var articleLabel: UILabel!
    @IBOutlet weak private var lastPictureLabel: UILabel!
    @IBOutlet weak private var articleView: UIView!
    @IBOutlet weak private var lastPictureView: UIView!
    
    private var newsViewModel = NewsViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsViewModel.$article
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.articleTableView.reloadData()
                }
            }
            .store(in: &cancellables)
        
        newsViewModel.$picture
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.pictureTableView.reloadData()
                }
            }
            .store(in: &cancellables)
        setUI()
    }
    
    func setUI() {
        articleLabel.text = articleLabel.text?.uppercased()
        lastPictureLabel.text = lastPictureLabel.text?.uppercased()
        setUIView(view: [articleView, lastPictureView])
    }
    
    @IBAction func reloadPicture() {
        newsViewModel.loadPicture()
        pictureTableView.reloadData()
    }
}


extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case pictureTableView:
            return newsViewModel.picture.count
        case articleTableView:
            return newsViewModel.article.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case pictureTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "pictureCell", for: indexPath) as? PictureTableViewCell else {
                return UITableViewCell()
            }
            let reverseIndex = newsViewModel.picture.count - 1 - indexPath.row
            guard reverseIndex >= 0 && reverseIndex < newsViewModel.picture.count else { return cell }
            let picture = newsViewModel.picture[reverseIndex].toPicture()
            cell.configure(title: picture.title, image: picture.imageURL, mediaType: picture.mediaType, date: picture.date)
            return cell
        case articleTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as? ArticleTableViewCell else {
                return UITableViewCell()
            }
            guard indexPath.row < newsViewModel.article.count else { return cell }
            let article = newsViewModel.article[indexPath.row]
            cell.configure(title: article.title, subtitle: article.subtitle, image: article.image)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView {
        case pictureTableView:
            let reverseIndex = newsViewModel.picture.count - 1 - indexPath.row
            guard reverseIndex >= 0 && reverseIndex < newsViewModel.picture.count else { return }
            let selectedPicture = newsViewModel.picture[reverseIndex].toPicture()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailPictureViewController") as? DetailPictureViewController else { return }
            detailViewController.picture = selectedPicture
            self.navigationController?.pushViewController(detailViewController, animated: true)
        case articleTableView:
            guard indexPath.row < newsViewModel.article.count else { return }
            let selectedArticle = newsViewModel.article[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailArticleVC = storyboard.instantiateViewController(withIdentifier: "DetailArticleViewController") as? DetailArticleViewController else { return }
            detailArticleVC.article = selectedArticle
            self.navigationController?.pushViewController(detailArticleVC, animated: true)
        default:
            break
        }
    }
}
