//
//  ListCellViewModel.swift
//  Demo
//
//  Created by SKEB2281 on 2021/4/16.
//

import UIKit

class ListCellViewModel {
    
    var nameString: String
    var locationString: String
    var featureString: String
    var imageUrlString: String
    var onImageDownloaded: ((UIImage?) -> Void)?
    
    private let downloadImageQueue = OperationQueue()   
    
    
    init(nameValue: String, locationValue: String, featureValue: String, imageValue: String) {
        self.nameString = nameValue
        self.locationString = locationValue
        self.featureString = featureValue
        self.imageUrlString = imageValue
    }
    
    
    
    func getImage() {
        guard let url = URL(string: imageUrlString) else { return }
        downloadImageQueue.addOperation { [weak self] in
           do {
               let data = try Data(contentsOf: url)
               let image = UIImage(data: data)
               guard let imageDownloaded = self?.onImageDownloaded else { return }
               imageDownloaded(image)
            
           } catch let error {
               print([error.localizedDescription])
           }
        }
    }
    
}
