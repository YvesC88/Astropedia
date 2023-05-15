//
//  NewsViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit

class NewsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var lastPictureLabel: UILabel!
    @IBOutlet weak var articleView: UIView!
    @IBOutlet weak var detailArticleView: UIView!
    @IBOutlet weak var lastPictureView: UIView!
    @IBOutlet weak var insideArticleView: UIView!
    @IBOutlet weak var detailArticleImageView: UIImageView!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var globalScrollView: UIScrollView!
    
    let pictureService = PictureService()
    let refreshControl = UIRefreshControl()
    var article: FirebaseArticle!
    
    private var picture: [APIApod] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        setupViews()
        loadingData()
    }
    
    private func loadingData() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        tableView.backgroundView = spinner
    }
    
    private func setupViews() {
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        articleLabel.text = articleLabel.text?.uppercased()
        lastPictureLabel.text = lastPictureLabel.text?.uppercased()
        self.setUIView(view: [articleView, detailArticleView, lastPictureView])
        detailArticleView.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
        setRefreshControl()
        loadArticle()
    }
    
    private func loadArticle() {
        let service = FirebaseDataService(wrapper: FirebaseWrapper())
        service.fetchArticle(collectionID: "article") { article, error in
            for article in article {
                self.article = article
                var articlesText: String = ""
                for text in article.articleText {
                    articlesText += "\(text)\n \n"
                }
                self.detailTextView.text = articlesText
                self.detailTitleLabel.text = article.title
                self.subtitleLabel.text = article.subTitle
                self.titleLabel.text = article.title
                if let url = URL(string: article.image) {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        guard let imageData = data else { return }
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(data: imageData)
                            self.detailArticleImageView.image = UIImage(data: imageData)
                        }
                    }.resume()
                }
            }
        }
    }
    
    private func setRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        globalScrollView.addSubview(refreshControl)
    }
    
    @objc private func refreshTableView() {
        refreshControl.endRefreshing()
        fetchData()
    }
    
    private func fetchData() {
        let date = Date()
        let dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -1, to: date)
        let startDate = self.getFormattedDate(date: start!, dateFormat: dateFormat)
        let newDate = calendar.date(byAdding: .day, value: -5, to: date)
        let endDate = self.getFormattedDate(date: newDate!, dateFormat: dateFormat)
        pictureService.getPicture(startDate: endDate, endDate: startDate) { picture in
            if let picture = picture {
                self.picture = picture
                self.tableView.backgroundView = nil
            }
        }
    }
    
    @IBAction func didTappedArticle(_ sender: Any) {
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [], animations: {
            self.detailArticleView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    @IBAction func closeDetailArticle() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: [], animations: {
            self.detailArticleView.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
        }, completion: nil)
    }
    
    @IBAction func didSharedArticle() {
        if let url = URL(string: article.source) {
            UIApplication.shared.open(url)
        }
    }
}


extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        picture.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pictureCell", for: indexPath) as? PresentPictureCell else {
            return UITableViewCell()
        }
        guard indexPath.row < picture.count else { return cell }
        let picture = picture[indexPath.row]
        cell.configure(title: picture.title, image: picture.url)
        return cell
    }
}

extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < picture.count {
            let picture = picture[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let customViewController = storyboard.instantiateViewController(withIdentifier: "DetailFavoriteViewController") as! DetailPictureViewController
            customViewController.picture = picture.toPicture()
            self.navigationController?.pushViewController(customViewController, animated: true)
        }
    }
}
