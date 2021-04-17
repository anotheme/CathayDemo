//
//  ViewController.swift
//  Demo
//
//  Created by SKEB2281 on 2021/4/12.
//

import UIKit
import Alamofire
import SwiftyJSON


class MainViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var boardView: UIView!
    @IBOutlet weak var boardLabel: UILabel!
    @IBOutlet weak var customNavigationBar: UINavigationBar!
    var boardViewOriginalHeight: CGFloat = 0
    var titleLabel: UILabel = UILabel()
    var lastVerticalOffset: CGFloat = 0
    
    var headerView: HeaderView!
    var pageSize = 20
    // 跳過幾筆(一次加pageSize筆)
    var offset = 0
    var loadFlag = false
    //tableView資料
    var dataArray: [AquireModel]?
    let viewModel = ViewControllerViewModel()



    override func viewDidLoad() {
        super.viewDidLoad()
        
        customNavigationBar.tintColor = UIColor.black
        
        let item = UINavigationItem(title: "")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.sizeToFit()
        item.titleView = titleLabel
        customNavigationBar.pushItem(item, animated: true)
        
        
//        boardView.layoutIfNeeded()
        boardViewOriginalHeight = boardView.frame.size.height
        tableView.contentInset = UIEdgeInsets(top: boardViewOriginalHeight, left: 0, bottom: 0, right: 0)
//        tableView.bounces = false
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleLabel.alpha = 0
        boardView.alpha = 1
        callAPI()
    }
    
    
    
    func prevLoad(){
        if(self.offset == 0) {
            self.offset = 0
        } else {
            self.offset -= 20
        }
        callAPI()
        boardView.alpha = 1
        boardLabel.alpha = 1
    }
    
    
    
    func moreLoad(){
        self.offset += 20
        callAPI()
    }
    
    
    
    func callAPI(){
        if !loadFlag {
            loadFlag = true
            
            Utitly.startLoading(myView: self.view)
            ApiShared.shared.queryApi(url: "https://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=f18de02f-b6c9-47c0-8cda-50efad621c14&sort=id&limit=\(self.pageSize)&offset=\(self.offset)")
            { (resultData, msg) in
                
                self.loadFlag = false
                Utitly.stopLoading()
                
                
                if let result = [AquireModel].deserialize(from: resultData) {

                    self.dataArray = result as? [AquireModel] ?? []
                    
                    if self.dataArray?.count == 0 {
                        Utitly.showAlert(self, title: "提醒", msg: "已無更多資料", confirmTitle: "確定")
                        return
                    }
                    
                    self.titleLabel.text = "\(self.dataArray?[0]._id ?? "") - \(self.dataArray?[self.dataArray!.count - 1]._id ?? "")"
                    self.titleLabel.sizeToFit()
                    
                    self.boardLabel.text = "\(self.dataArray?[0]._id ?? "") - \(self.dataArray?[self.dataArray!.count - 1]._id ?? "")"

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.scrollToTop()
                    }
                }
            }
        }
        
    }
    
    
    
    private func scrollToTop() {
        let topRow = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
}



extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?.first as? HeaderView
        headerView.headerLabel.alpha = 0
        return headerView
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pageSize
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else { return UITableViewCell() }
        
        //**********  MVVM寫法  **********
        if self.dataArray?.count != 0 && self.dataArray?.count != nil {
            let listCellViewModel = ListCellViewModel(nameValue: self.dataArray?[indexPath.row].F_Name_Ch ?? "",
                                                      locationValue: self.dataArray?[indexPath.row].F_Location ?? "",
                                                      featureValue: self.dataArray?[indexPath.row].F_Feature ?? "",
                                                      imageValue: self.dataArray?[indexPath.row].F_Pic01_URL ?? "")
            cell.setup(viewModel: listCellViewModel)
        }
        
        
        //**********  MVC寫法  **********
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
//        if self.dataArray?.count != 0 {
//            cell.nameLabel?.text = "\(self.dataArray?[indexPath.row].F_Name_Ch ?? "")"
//            cell.locationLabel?.text = "位置：\(self.dataArray?[indexPath.row].F_Location ?? "")"
//            cell.featureLabel?.text = "特徵：\(self.dataArray?[indexPath.row].F_Feature ?? "")"
//            cell.featureLabel.sizeToFit()
//            cell.picImageView?.downloaded(from: self.dataArray?[indexPath.row].F_Pic01_URL ?? "")
//        }
        return cell
    }
 
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //順著custom cell高度
        return UITableView.automaticDimension
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let verticalOffset = scrollView.contentOffset.y
        let scrollAmount = verticalOffset - lastVerticalOffset  //get scrolling amount since last update
        lastVerticalOffset = verticalOffset
        let alphaVariation = scrollAmount/(boardViewOriginalHeight/2)
        
        var newConstant = -verticalOffset
        
//        print("alphaVariation : \(alphaVariation)")
        
        if headerView != nil && alphaVariation < 1 && alphaVariation > -1{
            switch newConstant {
            case _ where newConstant <= 0:
                newConstant = 1
                titleLabel.alpha = 1
                headerView.headerLabel.alpha = 1
                //alphaVariation 往上是 0 ;  往下是 -
            case 1..<boardViewOriginalHeight/2:
                boardView.alpha = 1 - titleLabel.alpha - 0.6
                boardLabel.alpha = 1 - titleLabel.alpha - 0.6
                titleLabel.alpha = titleLabel.alpha + alphaVariation
                headerView.headerLabel.alpha = titleLabel.alpha
                break
            case boardViewOriginalHeight/2...boardViewOriginalHeight:
                boardView.alpha = 1 - titleLabel.alpha - 0.6
                boardLabel.alpha = 1 - titleLabel.alpha - 0.6
                headerView.headerLabel.alpha = titleLabel.alpha
                
                break
            case _ where newConstant > boardViewOriginalHeight:
                newConstant = boardViewOriginalHeight
                boardView.alpha = 1
                boardLabel.alpha = 1
                headerView.headerLabel.alpha = 0
            default:
                break
            }
            
            tableView.contentInset = UIEdgeInsets(top: newConstant, left: 0, bottom: 0, right: 0)
        }
    }
    
    
    
    //偵測到頂部或是底部
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            if !loadFlag {
                prevLoad()
            }
        } else {
            if !loadFlag {
                moreLoad()
            }
        }
    }
}







