//
//  NewsViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit

class NewsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    let pictureService = PictureService()
    let refreshControl = UIRefreshControl()
    
    private var picture: [APIApod] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchData()
        
        
        //        imageView.layer.cornerRadius = 15
        //        imageView.clipsToBounds = true
        //        fetchData()
        //        loadingData()
        //        setRefreshControl()
        //        loadArticle()
    }
    
    private func setupViews() {
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        setRefreshControl()
        loadArticle()
        loadingSpinner()
    }
    
    private func loadingSpinner() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        tableView.backgroundView = spinner
    }
    
    func loadArticle() {
        let service = FirebaseDataService(wrapper: FirebaseWrapper())
        service.fetchArticle(collectionID: "article") { article, error in
            for article in article {
                self.textView.text = article.text
                self.titleLabel.text = article.title
                if let data = try? Data(contentsOf: URL(string: article.image)!) {
                    self.imageView.image = UIImage(data: data)
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
        let info = UIImage(systemName: "info.circle.fill")
        cell.accessoryType = .detailButton
        cell.accessoryView = UIImageView(image: info)
        cell.accessoryView?.tintColor = UIColor.systemBlue
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
