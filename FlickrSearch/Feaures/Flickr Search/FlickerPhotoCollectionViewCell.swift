//
//  FlickerPhotoCollectionViewCell.swift
//  FlickrSearch
//
//  Created by Gaurav Singh on 21/07/18.
//  Copyright © 2018 Gaurav Singh. All rights reserved.
//

import UIKit

class FlickerPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.image = #imageLiteral(resourceName: "blur-placeholder")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = #imageLiteral(resourceName: "blur-placeholder")
    }
}
