//
//  HomeViewController.swift
//  DriverReadyToEat
//
//  Created by casperonios on 10/11/17.
//  Copyright © 2017 CasperonTechnologies. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import EZSwiftExtensions

class HomeViewController: UIViewController,GMSMapViewDelegate{
    
    //After Designed Changed Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var lastPaidEarningsLbl: UILabel!
    @IBOutlet weak var supportBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var earningsViewInView: UIView!
    
    var currentLocat_Btn:UIButton = UIButton()
    var current_Lat:String!
    var current_Long:String!
    var getLatLong_Add:String = String()
    var myLocation: CLLocation?
    
    var past7Dates = [String]()
    var past7Days = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "EarningsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EarningsCollectionViewCell")
        collectionView.register(UINib(nibName: "EarningsSeeAllACollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EarningsSeeAllACollectionViewCell")
        self.setupMapView()
        past7Dates = Date.getDates(forLastNDays: 7).0 as [String]
        past7Days  =  Date.getDates(forLastNDays: 7).1 as [String]
        print(past7Dates,past7Days)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    //MARK:- Update UI
    func updateUI(){
        TheGlobalPoolManager.cornerAndBorder(self.earningsViewInView, cornerRadius: 8, borderWidth: 0.5, borderColor: .lightGray)
        TheGlobalPoolManager.cornerRadiusForParticularCornerr(self.earningsViewInView, corners: [.bottomRight,.topRight], size: CGSize(width: 8, height: 0))
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 100, height: self.collectionView.frame.height)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        collectionView!.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    func setupMapView() {
        ModelClassManager.myLocation()
        ModelClassManager.delegate = self
        mapView.delegate = self
        self.updateUI()
    }
    func setMap_View(lat:String,long:String){
        var lati = String()
        var longti = String()
        lati = lat
        longti = long
        let UpdateLoc = CLLocationCoordinate2DMake(CLLocationDegrees(lati)!,CLLocationDegrees(longti)!)
        let camera = GMSCameraPosition.camera(withTarget: UpdateLoc, zoom: 18)
        let userLocationMarker = GMSMarker(position: UpdateLoc)
        userLocationMarker.map = mapView
        mapView.animate(to: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    //MARK : - Support Button Method
    func supportBtnMethod(){
        let helpVC = self.storyboard?.instantiateViewController(withIdentifier: "HelpSupportViewControllerID") as! HelpSupportViewController
        self.navigationController?.pushViewController(helpVC, animated: true)
    }
    //MARK : - Pushing To Your  Earnings View Controller
    func pushingToYourEarningsVC() {
        if let viewCon = self.storyboard?.instantiateViewController(withIdentifier: "YourEarningsViewControllerID") as? YourEarningsViewController{
            self.navigationController?.pushViewController(viewCon, animated: true)
        }
    }
    //MARK:- IB Action Outlets
    @IBAction func supportBtn(_ sender: UIButton) {
        self.supportBtnMethod()
    }
}
extension UIImage {
    func makeImageWithColorAndSize(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
extension HomeViewController : ModelClassManagerDelegate{
    func delegateForLocationUpdate(_ viewCon: SingleTonClass, location: CLLocation) {
        print("Delegate Called IN AddDeliveryLocationVC")
        self.myLocation = location
        if current_Lat == nil && current_Long == nil{
            current_Lat = "\(location.coordinate.latitude)"
            current_Long = "\(location.coordinate.longitude)"
        }
        self.setMap_View(lat: (current_Lat as NSString) as String, long: (current_Long as NSString) as String)
    }
}
extension HomeViewController : UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EarningsSeeAllACollectionViewCell", for: indexPath as IndexPath) as! EarningsSeeAllACollectionViewCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EarningsCollectionViewCell", for: indexPath as IndexPath) as! EarningsCollectionViewCell
        if indexPath.row % 2 == 0 {
            cell.paidStatusLbl.backgroundColor = .greenColor
        }
        cell.dateLbl.text =  " \(past7Days[indexPath.row])\n\(past7Dates[indexPath.row])"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.item)!")
        if indexPath.row == 2{
            self.pushingToYourEarningsVC()
        }
    }
}

