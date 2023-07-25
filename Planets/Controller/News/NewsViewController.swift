//
//  NewsViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit

class NewsViewController: UIViewController {
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var pictureTableView: UITableView!
    @IBOutlet weak private var articleTableView: UITableView!
    @IBOutlet weak private var articleLabel: UILabel!
    @IBOutlet weak private var lastPictureLabel: UILabel!
    @IBOutlet weak private var articleView: UIView!
    @IBOutlet weak private var lastPictureView: UIView!
    @IBOutlet weak private var errorLabel: UILabel!
    
    private let pictureService = PictureService(wrapper: FirebaseWrapper())
    private let articleService = ArticleService(wrapper: FirebaseWrapper())
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        articleService.articleDelegate = self
        pictureService.pictureDelegate = self
        setupViews()
    }
    
    private final func setupViews() {
        articleLabel.text = articleLabel.text?.uppercased()
        lastPictureLabel.text = lastPictureLabel.text?.uppercased()
        setUIView(view: [articleView, lastPictureView])
        articleService.loadArticle()
        pictureService.loadPicture()
    }
}


extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case pictureTableView:
            return pictureService.picture.count
        case articleTableView:
            return articleService.article.count
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
            let reverseIndex = pictureService.picture.count - 1 - indexPath.row
            guard reverseIndex >= 0 && reverseIndex < pictureService.picture.count else { return cell }
            let picture = pictureService.picture[reverseIndex].toPicture()
            cell.configure(title: picture.title, image: picture.imageURL, mediaType: picture.mediaType)
            return cell
        case articleTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as? ArticleTableViewCell else {
                return UITableViewCell()
            }
            guard indexPath.row < articleService.article.count else { return cell }
            let article = articleService.article[indexPath.row]
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
            let reverseIndex = pictureService.picture.count - 1 - indexPath.row
            guard reverseIndex >= 0 && reverseIndex < pictureService.picture.count else { return }
            let selectedPicture = pictureService.picture[reverseIndex].toPicture()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailPictureViewController") as? DetailPictureViewController else { return }
            detailViewController.picture = selectedPicture
            self.navigationController?.pushViewController(detailViewController, animated: true)
        case articleTableView:
            guard indexPath.row < articleService.article.count else { return }
            let selectedArticle = articleService.article[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailArticleVC = storyboard.instantiateViewController(withIdentifier: "DetailArticleViewController") as? DetailArticleViewController else { return }
            detailArticleVC.article = selectedArticle
            self.navigationController?.pushViewController(detailArticleVC, animated: true)
        default:
            break
        }
    }
}

extension NewsViewController: ArticleDelegate {
    func reloadArticleTableView() {
        DispatchQueue.main.async {
            self.articleTableView.reloadData()
        }
    }
}

extension NewsViewController: PictureDelegate {
    
    func startAnimating() {
        spinner.startAnimating()
        pictureTableView.backgroundView = spinner
    }
    
    func stopAnimating() {
        spinner.stopAnimating()
    }
    
    func reloadPictureTableView() {
        DispatchQueue.main.async {
            self.pictureTableView.reloadData()
        }
    }
    
    func showErrorLoading(text: String, isHidden: Bool) {
        errorLabel.isHidden = isHidden
        errorLabel.text = text
    }
}
