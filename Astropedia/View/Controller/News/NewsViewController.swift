//
//  NewsViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 09/05/2023.
//

import UIKit
import Combine

final class NewsViewController: UIViewController {
    
    @IBOutlet weak private var scrollView: UIScrollView!
    @IBOutlet weak private var pictureTableView: UITableView!
    @IBOutlet weak private var articleTableView: UITableView!
    @IBOutlet weak private var articleLabel: UILabel!
    @IBOutlet weak private var pictureLabel: UILabel!
    @IBOutlet weak private var articleView: UIView!
    @IBOutlet weak private var pictureView: UIView!
    @IBOutlet weak private var globalView: UIView!
    
    private var newsViewModel = NewsViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private var lastContentOffset: CGFloat = 0.0
    private let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        scrollView.delegate = self
        newsViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.newsViewModel.isLoading == true {
                    self?.spinner.startAnimating()
                } else {
                    self?.spinner.stopAnimating()
                }
            }
            .store(in: &cancellables)
        updateUI(data: newsViewModel.$article, tableView: articleTableView)
        updateUI(data: newsViewModel.$picture, tableView: pictureTableView)
    }
    
    private final func setUI() {
        
        // MARK: - Background Image
        let backgroundView = UIImageView(image: UIImage(named: "BGNews"))
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.frame.size = globalView.frame.size
        globalView.insertSubview(backgroundView, at: 0)
        
        // MARK: - BlurEffect
        applyBlurEffect(to: articleView, withCornerRadius: 20)
        applyBlurEffect(to: pictureView, withCornerRadius: 20)
        
        spinner.hidesWhenStopped = true
        spinner.center = pictureTableView.center
        pictureTableView.addSubview(spinner)
    }
    
    // MARK: - To refresh tableView and update picture or article with Combine
    private final func updateUI<T>(data: Published<[T]>.Publisher, tableView: UITableView) {
        data
            .receive(on: DispatchQueue.main)
            .sink { _ in
                tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @IBAction func reloadPicture() {
        updateUI(data: newsViewModel.$picture, tableView: pictureTableView)
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
            let reverseCollection = newsViewModel.picture.reversed()
            guard indexPath.row >= 0 && indexPath.row < reverseCollection.count else { return cell}
            let picture = reverseCollection[reverseCollection.index(reverseCollection.startIndex, offsetBy: indexPath.row)].toPicture()
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
            let reverseCollection = newsViewModel.picture.reversed()
            guard indexPath.row >= 0 && indexPath.row < reverseCollection.count else { return }
            let selectedPicture = reverseCollection[reverseCollection.index(reverseCollection.startIndex, offsetBy: indexPath.row)].toPicture()
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

extension NewsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        if currentOffset > lastContentOffset && currentOffset > 0 {
            UIView.animate(withDuration: 0.5) {
                self.tabBarController?.tabBar.alpha = 0
            }
        } else if currentOffset < lastContentOffset || currentOffset == 0 {
            self.tabBarController?.tabBar.alpha = 1
        }
        lastContentOffset = currentOffset
    }
}
