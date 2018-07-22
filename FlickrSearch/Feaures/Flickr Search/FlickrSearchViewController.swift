//
//  FlickrSearchViewController.swift
//  FlickrSearch
//
//  Created by Gaurav Singh on 21/07/18.
//  Copyright © 2018 Gaurav Singh. All rights reserved.
//

import UIKit
import SafariServices

class FlickrSearchViewController: UIViewController {
    
    private var searchController: UISearchController!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var loadingSpinner: UIActivityIndicatorView!
    
    private var photoURLs = [URL]()
    
    private static let LOAD_MORE_DISTANCE: CGFloat = 100
    
    private var presenter: FlickrSearchPresenter = FlickrSearchPresenter(service: FlickrService())

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        
        presenter.attachView(view: self)
    }

    private func configureView() {
        
        title = "Flicker Search"
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Images"
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        
        collectionView.register(UINib(nibName: FlickerPhotoCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: FlickerPhotoCollectionViewCell.className)
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        // Calculate CollectionView Cell size
        let width = (UIScreen.main.bounds.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right) - 2 * flowLayout.minimumInteritemSpacing) / 3
        
        // Set CollectionView Cell size
        flowLayout.itemSize = CGSize(width: width, height: width)
        
    }
    
    private func showImage(atIndex index: Int) {
        if let imageURL = presenter.getImageURL(atIndex: UInt(index)) {
            let safariController = SFSafariViewController(url: imageURL)
            navigationController?.present(safariController, animated: true, completion: nil)
        }
    }
    
    func showError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}

extension FlickrSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text, !query.isEmpty {
            presenter.searchFlickr(forQuery: query)
        }
    }
    
}

extension FlickrSearchViewController: FlickrSearchView {
    
    func searchViewDidStartLoading(isNewSearch: Bool) {
        if isNewSearch {
            loadingSpinner.startAnimating()
        }
    }
    
    func searchViewDidFinishedLoading(isNewSearch: Bool, urls: [URL]?, error: Error?) {
        loadingSpinner.stopAnimating()
        guard let urls = urls else {
            if isNewSearch {
                showError(message: error?.localizedDescription ?? FSError.unknownResponse.localizedDescription)
            }
            return
        }
        
        if isNewSearch {
            photoURLs = urls
            collectionView.reloadData()
        } else {
            var indexPathsToInsert = [IndexPath]()
            for index in photoURLs.count..<(photoURLs.count + urls.count) {
                indexPathsToInsert.append(IndexPath(item: index, section: 0))
            }
            
            collectionView.performBatchUpdates({ [weak self] in
                self?.photoURLs.append(contentsOf: urls)
                self?.collectionView.insertItems(at: indexPathsToInsert)
            }, completion: nil)
        }
    }
}

extension FlickrSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlickerPhotoCollectionViewCell.className, for: indexPath) as! FlickerPhotoCollectionViewCell
        
        // cell may get reused before getting the image from network. Hence indexPath is stored in the cell so that it can be compared inside the block
        cell.indexPath = indexPath
        if indexPath.item < photoURLs.count {
            let url = photoURLs[indexPath.item]
            ImageCacheManager.shared.loadImage(forURL: url) { [weak cell] (cachedImage) in
                if
                    let image = cachedImage,
                    let weakCell = cell,
                    weakCell.indexPath == indexPath {
                    weakCell.imageView.image = image
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showImage(atIndex: indexPath.item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if photoURLs.count > 0 && scrollView.contentSize.height > scrollView.bounds.height && scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - FlickrSearchViewController.LOAD_MORE_DISTANCE {
            presenter.loadMore()
        }
    }
    
}
