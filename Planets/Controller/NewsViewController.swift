//
//  NewsViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit

class NewsViewController: UIViewController {
    @IBOutlet weak private var pictureTableView: UITableView!
    @IBOutlet weak private var articleTableView: UITableView!
    @IBOutlet weak private var articleLabel: UILabel!
    @IBOutlet weak private var lastPictureLabel: UILabel!
    @IBOutlet weak private var articleView: UIView!
    @IBOutlet weak private var lastPictureView: UIView!
    @IBOutlet weak private var globalScrollView: UIScrollView!
    @IBOutlet weak private var refreshButton: UIButton!
    
    let pictureService = PictureService()
    let spinner = UIActivityIndicatorView(style: .medium)
    
    private var picture: [APIApod] = [] {
        didSet {
            DispatchQueue.main.async {
                self.pictureTableView.reloadData()
            }
        }
    }
    
    private var article: [FirebaseArticle] = [] {
        didSet {
            DispatchQueue.main.async {
                self.articleTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private final func setupViews() {
        articleLabel.text = articleLabel.text?.uppercased()
        lastPictureLabel.text = lastPictureLabel.text?.uppercased()
        self.setUIView(view: [articleView, lastPictureView])
        loadArticle()
        fetchData()
    }
    
    private final func loadArticle() {
        let service = FirebaseDataService(wrapper: FirebaseWrapper())
        service.fetchArticle(collectionID: "article") { article, error in
            for data in article {
                self.article.append(data)
            }
        }
    }
    
    private final func fetchData() {
        spinner.startAnimating()
        pictureTableView.backgroundView = spinner
        let date = Date()
        let dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -1, to: date)
        let startDate = self.getFormattedDate(date: start!, dateFormat: dateFormat)
        let newDate = calendar.date(byAdding: .day, value: -7, to: date)
        let endDate = self.getFormattedDate(date: newDate!, dateFormat: dateFormat)
        pictureService.getPicture(startDate: endDate, endDate: startDate) { picture in
            if let picture = picture {
                self.picture = picture
                self.spinner.stopAnimating()
            }
        }
    }
    
    @IBAction func didTappedRefresh() {
        loadArticle()
        fetchData()
    }
}


extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case pictureTableView:
            return picture.count
        case articleTableView:
            return article.count
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
            guard indexPath.row < picture.count else { return cell }
            let picture = picture[indexPath.row]
            cell.configure(title: picture.title, image: picture.url)
            return cell
        case articleTableView:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as? ArticleTableViewCell else {
                return UITableViewCell()
            }
            guard indexPath.row < article.count else { return cell }
            let article = article[indexPath.row]
            cell.configure(title: article.title, subtitle: article.subTitle, image: article.image)
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
            guard indexPath.row < picture.count else { return }
            let selectedPicture = picture[indexPath.row]
            selectedPicture.toPicture { [weak self] picture in
                guard let self = self, let picture = picture else {
                    return
                }
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailPictureViewController") as! DetailPictureViewController
                    detailViewController.picture = picture
                    self.navigationController?.pushViewController(detailViewController, animated: true)
                }
            }
        case articleTableView:
            guard indexPath.row < article.count else { return }
            let selectedFirebaseArticle = article[indexPath.row]
            selectedFirebaseArticle.toArticle { [weak self] article in
                guard let self = self, let article = article else {
                    return
                }
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let detailViewController = storyboard.instantiateViewController(withIdentifier: "DetailArticleViewController") as! DetailArticleViewController
                    detailViewController.article = article
                    self.navigationController?.pushViewController(detailViewController, animated: true)
                }
            }
        default:
            break
        }
    }
}
