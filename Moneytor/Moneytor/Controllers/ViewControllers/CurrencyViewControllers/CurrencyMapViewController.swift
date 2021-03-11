//
//  CurrencyMapViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit
import MapKit

class CurrencyMapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var currencyMapView: MKMapView!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let userDefaultRegionKey: String = "saveRegion"
    var locationAnnotation: MKPointAnnotation!
    var canLogin:Bool = true
    var totalExpenses: Double = 0.0
    var totalIncomes: Double = 0.0
    var totalBalance: Double = 0.0
    var countynameFromPlackMark: String = ""
    var codeCurrencyConvert: String = ""
    var rateCurrencyConvert: Double = 0.0
    var resultCurrencyConvert: Double = 0.0
    
    var keyLat: Float = 49.2888
    var keyLon : Float = -123.111
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        // view.addGestureRecognizer(tap)
        
        currencyMapView.delegate = self
       // currencyMapView.isZoomEnabled = false
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        longPressRecogniser.minimumPressDuration = 0.2
        currencyMapView.addGestureRecognizer(longPressRecogniser)
        currencyMapView.mapType = MKMapType.standard
        let location = CLLocationCoordinate2D(latitude: CLLocationDegrees(keyLat), longitude: CLLocationDegrees(keyLon))
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: location, span: span)
        currencyMapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Canada Place"
        annotation.subtitle = "SomeWhere"
        currencyMapView.addAnnotation(annotation)
    }
    
    @objc func handleTap(_ gesturesReconizer: UILongPressGestureRecognizer) {
        
        print("-------------------- : Tapped in \(#function) : ----------------------------\n)")
        let location = gesturesReconizer.location(in: currencyMapView)
        let coordinate = currencyMapView.convert(location, toCoordinateFrom: currencyMapView)
        
        let annototion = MKPointAnnotation()
        annototion.coordinate = coordinate
        annototion.title = "Tap"
        currencyMapView.addAnnotation(annototion)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let latVarStr = "\(view.annotation?.coordinate.latitude)"
        let longVarStr = "\(view.annotation?.coordinate.longitude)"
        print("-----------------  latVarStr::  \(latVarStr) ,longVarStr:: \(longVarStr)-----------------")
    }
    
    
    
    // MARK: - Actions
    @IBAction func logoutButtonTapped(_ sender: Any) {
    }
    
    
    
}

