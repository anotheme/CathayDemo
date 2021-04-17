//
//  TableViewCell.swift
//  Demo
//
//  Created by SKEB2281 on 2021/4/15.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var locationLabel: UILabel?
    @IBOutlet var featureLabel: UILabel!
    @IBOutlet var picImageView: UIImageView!
    
    private var viewModel: ListCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(viewModel: ListCellViewModel) {
        self.viewModel = viewModel
        
        self.nameLabel?.text = viewModel.nameString
        self.locationLabel?.text = viewModel.locationString
        self.featureLabel?.text = viewModel.featureString
        
        self.viewModel?.onImageDownloaded = { [weak self] image in
            DispatchQueue.main.async {
                self?.picImageView?.image = image
            }
        }
        self.viewModel?.getImage()
    }
}


