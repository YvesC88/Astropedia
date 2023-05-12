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
    @IBOutlet weak var subtextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var lastPictureLabel: UILabel!
    @IBOutlet weak var articleView: UIView!
    @IBOutlet weak var detailArticleView: UIView!
    @IBOutlet weak var lastPictureView: UIView!
    @IBOutlet weak var detailArticleImageView: UIImageView!
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    
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
        loadingSpinner()
    }
    
    private func loadingSpinner() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        tableView.backgroundView = spinner
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
                self.subtextView.text = article.subTitle
                self.titleLabel.text = article.title
                if let data = try? Data(contentsOf: URL(string: article.image)!) {
                    self.imageView.image = UIImage(data: data)
                    self.detailArticleImageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    private func setRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc private func refreshTableView() {
        tableView.reloadData()
        refreshControl.endRefreshing()
        fetchData()
    }
    
    private func fetchData() {
        let date = Date()
        let dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -1, to: date)
        let startDate = self.getFormattedDate(date: start!, dateFormat: dateFormat)
        let newDate = calendar.date(byAdding: .day, value: -3, to: date)
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
        let picture = picture[indexPath.row].toPicture()
        cell.configure(title: picture.title!, image: picture.imageSD!)
        return cell
    }
}

extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < picture.count {
            let picture = picture[indexPath.row].toPicture()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let customViewController = storyboard.instantiateViewController(withIdentifier: "DetailFavoriteViewController") as! DetailFavoriteViewController
            customViewController.picture = picture
            self.navigationController?.pushViewController(customViewController, animated: true)
        }
    }
    
}
