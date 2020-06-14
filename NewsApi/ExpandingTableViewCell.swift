//
//  ExpandingTableViewCell.swift
//  NewsApi
//
//  Created by Faizyy on 13/06/20.
//  Copyright © 2020 faiz. All rights reserved.
//

import UIKit
import CoreData

class ExpandingTableViewCell: UITableViewCell {
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDescription: UILabel!
    
    var article: NSManagedObject? {
        didSet {
            if let data = article?.value(forKey: "imageData") as? Data {
                self.newsImage.image = UIImage(data: data)?.withRoundedCorners(radius: 75)
            }
            self.newsTitle.text = article?.value(forKey: "title") as? String
            self.newsDescription.text = article?.value(forKey: "desc") as? String
        }
    }
}

extension UIImage {
    // image with rounded corners
    public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
