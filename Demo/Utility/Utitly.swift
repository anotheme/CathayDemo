//
//  BaseViewController.swift
//  Demo
//
//  Created by SKEB2281 on 2021/4/13.
//

import UIKit




class Utitly: UIView {
    
   
    static let loadingIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    

    static var indicator = UIView()
    
    
    //Loading loadingIndicator
    static func startLoading (myView: UIView) {
        loadingIndicator.startAnimating()
        
        var found: Bool = false
        for subview in myView.subviews where subview.tag == 999{
            found = true
        }
        if !found {
            let view = UIView()
            let screen: CGRect = myView.bounds
            
            view.frame = screen
            view.backgroundColor = .lightGray
            view.alpha = 0.6
            view.tag = 999
//            view.addSubview(loadingIndicator)
            view.addSubViewWithConstraint(view: loadingIndicator)
            indicator = view
            
            myView.addSubview(view)
        }
    }
    
    
    
    //cancel loadingIndicator
    static func stopLoading () {
        self.indicator.removeFromSuperview()
    }
       
    
    //display alert
    static func showAlert(_ viewController:UIViewController,
                              title:String?,
                              msg:String?,
                              confirmTitle:String?
                              )
        {
            let alert = UIAlertController(title: title, message: msg, preferredStyle:UIAlertController.Style.alert)

            let confirmAction = UIAlertAction(title: confirmTitle, style: .default, handler: { (action: UIAlertAction!) in
//                completionHandler()
            })
            confirmAction.setValue(UIColor.red, forKey: "titleTextColor")

            alert.addAction(confirmAction)
            viewController.present(alert, animated: true, completion: nil)
        }
}



extension UIView{
    /// 從xib初始化
    public class func initFromNib<T: UIView>(xibName: String) -> T {
        return Bundle.main.loadNibNamed(xibName, owner: nil, options: nil)?[0] as! T
    }
    
    // 加入subview並設定中同等大小的constraint
    func addSubViewWithConstraint(view: UIView) {
        view.frame = self.bounds
        addSubview(view)
        
        // 設定constraint
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}


extension UIImageView{

    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
