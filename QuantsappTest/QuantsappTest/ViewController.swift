//
//  ViewController.swift
//  QuantsappTest
//
//  Created by Yash Raut on 27/07/21.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var filterArr = [(name: "All", clr: "#E69E3E"),(name: "L", clr: "00ff00"),(name: "S", clr: "ff0000"),(name: "LU", clr: "5BCEF4"),(name: "SC", clr: "ffff00")]

    var dataList = [dataMod]()
    var filteredDataList = [dataMod]()

    var selectedFilter = 0
    var searchActive : Bool = false

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var topCollView: UICollectionView!
    @IBOutlet var collView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        // Do any additional setup after loading the view.
    }
    
    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let sTxt = searchText
        let filteredArray = self.dataList.filter({($0.symbol.localizedCaseInsensitiveContains(sTxt))})
        self.filteredDataList = filteredArray
        self.collView.reloadData()
        
        if searchText == ""{
            filteredDataList = dataList
            collView.reloadData()
        }
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1{
            return filterArr.count
        }else if collectionView.tag == 2{
            return filteredDataList.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if collectionView.tag == 1{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath)
            let mainView = cell.viewWithTag(100)
            let lbl = mainView?.viewWithTag(101) as! UILabel
            
            mainView?.backgroundColor = UIColor(hexString: filterArr[indexPath.item].clr)
            mainView?.layer.cornerRadius = (mainView?.frame.height)!/2
            mainView?.clipsToBounds = true
            
            lbl.text = filterArr[indexPath.item].name
            
        }else if collectionView.tag == 2{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            let data = filteredDataList[indexPath.item]
            
            cell.layer.cornerRadius = 1
            cell.layer.borderWidth = 0.5
            cell.layer.borderColor = UIColor.lightGray.cgColor
            let mainView = cell.viewWithTag(100)
            let symbLbl = mainView?.viewWithTag(101) as! UILabel
            let percentLbl = mainView?.viewWithTag(102) as! UILabel
            
            symbLbl.text = data.symbol
            percentLbl.text = data.price_change_percent + " %"
            
            let clr = getClr(f: data.filter)
            mainView?.backgroundColor = clr
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 2{
            let width = (collectionView.frame.width / 3) - 2

            let height = width
            let cellSize = CGSize(width: width, height: CGFloat(height))
            return cellSize
        }
        return CGSize(width: CGFloat(100), height: CGFloat(45))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1{
            var f = "All"
            switch indexPath.item {
            case 1:
                f = "l"
            case 2:
                f = "s"
            case 3:
                f = "lu"
            case 4:
                f = "sc"
            default:
                f = "All"
            }
            
            filteredDataList.removeAll()
            selectedFilter = indexPath.item
            if indexPath.item > 0{
                let filteredArray = self.dataList.filter({($0.filter.elementsEqual(f))})

                self.filteredDataList = filteredArray
            }else{
                filteredDataList = dataList
            }
            collView.reloadData()
        }
    }

    func getData() {
        ServerManager().get(url: "https://qapptemporary.s3.ap-south-1.amazonaws.com/test/synopsis.json") { (result) in
                switch result{
                case .success(let response):
                       print(response)
                    
                    if let l = response["l"].string{
                        self.mapData(sym: "l", str: l)
                    }
                    if let s = response["s"].string{
                        self.mapData(sym: "s", str: s)
                    }
                    if let lu = response["lu"].string{
                        self.mapData(sym: "lu", str: lu)
                    }
                    if let sc = response["sc"].string {
                        self.mapData(sym: "sc", str: sc)
                    }


                                        
                case .failure(let err):
                    self.showAlert(title: "Error", message: "\(err)")
            }

        }
    }
    
    func mapData(sym: String, str: String) {
        let listArr = str.components(separatedBy: ";")

        for l in listArr {
            let d = dataMod()
            d.filter = sym
            let listData = l.components(separatedBy: ",")
            let symbol = listData[0]
            let price = listData[1]
            let open_interest = listData[2]
            let price_change_percent = listData[3]
            let open_interest_percent = listData[4]
            
            d.symbol = symbol
            d.price = price
            d.open_interest = open_interest
            d.price_change_percent = price_change_percent
            d.open_interest_percent = open_interest_percent
           
            dataList.append(d)
            filteredDataList.append(d)
            collView.reloadData()
        }
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func getClr(f: String) -> UIColor {
        
        switch f {
        case "l":
            return UIColor(hexString: "00ff00")
        case "s":
            return UIColor(hexString: "ff0000")
        case "lu":
            return UIColor(hexString: "5BCEF4")
        case "sc":
            return UIColor(hexString: "ffff00")
        default:
            return UIColor.white
        }
    }

}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
