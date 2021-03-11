//
//  CurrencyMapViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit
import MapKit

class CurrencyMapViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let userDefaultRegionKey: String = "saveRegion"
    //var pin: PinLocation?
    var locationAnnotation: MKPointAnnotation!
    //var fetchedResultsController: NSFetchedResultsController<PinLocation>!
    
    //MARK : LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //getPersistedLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //deleteButton.isEnabled = false
        // reloadLocation()
    }
    
    
    
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
            let locationCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            userGeoCoordination(from: locationCoordinate)
        }
        
    }
    
    // MARK: - Helper Fuctions
    
    
    func userGeoCoordination(from coordinate: CLLocationCoordinate2D) {
        let geoPos = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let annotation = MKPointAnnotation()
        CLGeocoder().reverseGeocodeLocation(geoPos) {(placemarks, error) in
            guard let placemark = placemarks?.first else {return}
            annotation.title = placemark.name ?? "Name Not Known !!"
            annotation.subtitle = placemark.country
            annotation.coordinate = coordinate
            self.locationForPin(annotation)
        }
    }
    
    func locationForPin(_ annotation: MKPointAnnotation) {
        let location = PinLocation(context: CoreDataStack.shared.context)
        location.date = Date()
        location.latitude = annotation.coordinate.latitude
        location.longitude = annotation.coordinate.longitude
        try? CoreDataStack.shared.saveContext()
        let locationPin = LocationPin(pin: location)
        self.mapView.addAnnotation(locationPin)
        
    }
    
    
    
    func reloadLocationPins() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        let pins = LocationPinController.shared.loctionPins
        
        self.mapView.addAnnotations(pins.map {pin in LocationPin(pin: pin)})
        
    }
    
    func saveUserRegion() {
        let mapRegion = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        UserDefaults.standard.set(mapRegion, forKey: userDefaultRegionKey)
    }
    
    func getPersistedLocation() {
        if let mapRegion = UserDefaults.standard.dictionary(forKey: userDefaultRegionKey) {
            let location = mapRegion as! [String: CLLocationDegrees]
            let center = CLLocationCoordinate2D(latitude: location["latitude"]!, longitude: location["longitude"]!)
            let span = MKCoordinateSpan(latitudeDelta: location["latitudeDelta"]!, longitudeDelta: location["longitudeDelta"]!)
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        }
    }
}

extension CurrencyMapViewController: MKMapViewDelegate {
    //When mapView changed, update and save user last region.
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.saveUserRegion()
    }
    
    //When mapView selected, set locationAnnotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let _ = view.annotation else {
            return
        }
        self.locationAnnotation = view.annotation as? MKPointAnnotation
        // deleteButton.isEnabled = true
    }
    
    //Using a reused pin to show on the mapView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        let pinAnnotation = annotation as! LocationPin
        
        let geoPos = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            guard let countryName = placemark.country else {return}
            print("----------------- selectedCountryName:: \(countryName)-----------------")
            let totalString = TotalController.shared.totalBalanceString
            print("----------------- totalString:: \(totalString)-----------------")
            
            
            CurrencyController.shared.calculatedCurrencyFromSelectedCountry(selectedCountryName: countryName, totalAmountString: totalString)
            let selectedCode = CurrencyController.shared.selectedCountryCode
            let resultCovert = CurrencyController.shared.resultConvertString
            let rate = CurrencyController.shared.rateString
            let baseCode = CurrencyController.shared.baseCountryCode
            let selectedCountryName = CurrencyController.shared.selectedCountryName
            pinAnnotation.title = "Balance in \(selectedCountryName) : \(resultCovert)."
            pinAnnotation.subtitle =  "Today \(selectedCode) Rate : \(rate) per 1 \(baseCode)."
            //pinAnnotation.subtitle =  "can I have the thired"
        }
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        //THIS IS THE GOOD BIT
//           let subtitleView = UILabel()
//        subtitleView.font = subtitleView.font.withSize(12)
//           subtitleView.numberOfLines = 0
//           subtitleView.text = annotation.subtitle!
//           pinView!.detailCalloutAccessoryView = subtitleView
        pinView?.reloadInputViews()
        return pinView
    }
    
    //When callout on Pit, save LocationPin and performSegue to PhotoAblumVC
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        guard let _ = view.annotation else {return}
        
        
        if let annotation = view.annotation as? MKPointAnnotation{
            
            print("----------------- annotation:: \(annotation)-----------------")
            
        }
        
    }

}





/*
 let pressPoint = sender.location(in: mapView)
 //        let pressCooridnate = mapView.convert(pressPoint,toCoordinateFrom: mapView)
 //        let pressPin = MapPin(coordinate: pressCooridnate, title: "press place", subtitle: "here is a subtitle")
 mapView.addAnnotation(pressPin)
 // MARK: - Outlets
 
 // MARK: - Actions
 @IBAction func logoutButtonTapped(_ sender: Any) {
 }
 
 let userDefaultRegionKey: String = "saveRegion"
 var locationAnnotation: MKPointAnnotation!
 var canLogin:Bool = true
 var totalExpenses: Double = 0.0
 var totalIncomes: Double = 0.0
 // var totalBalanceInString: Double = 0.0
 var countynameFromPlackMark: String = ""
 var codeCurrencyConvert: String = ""
 var rateCurrencyConvert: Double = 0.0
 var resultCurrencyConvert: Double = 0.0
 
 
 
 //MARK : LifeCycle
 override func viewDidLoad() {
 super.viewDidLoad()
 
 currencyMapView.delegate = self
 currencyMapView.isZoomEnabled = false
 activityIndicator.isHidden = true
 //totalBalance = fetchTotalSumsAndGetBalance()
 //  CheckUserLoggin()
 //converter.convert(amount: totalBalance, currency: .unitedState, into: .thailand)
 //   converter.convert(amount: 65000.00, currency: .thailand, into: .unitedState)
 
 }
 
 
 override func viewWillAppear(_ animated: Bool) {
 activityIndicator.isHidden = true
 print("----------------- :: viewWillAppear in MApCurrency-----------------")
 //            let result: () = converter.convert(amount: totalBalance, currency: .unitedState, into: .thailand)
 //            print("result:\(result)")
 
 }
 
 
 override func viewDidAppear(_ animated: Bool) {
 activityIndicator.isHidden = true
 
 }
 
 @IBAction func longPressGestureOnCurrencyMap(_ sender: UILongPressGestureRecognizer) {
 
 if sender.state == .ended {
 print("===================tap gesture==============================\(sender.state )")
 let touchPoint = sender.location(in: currencyMapView)
 let touchCoordinate = currencyMapView.convert(touchPoint, toCoordinateFrom: self.currencyMapView)
 let annotation = MKPointAnnotation()
 annotation.coordinate = touchCoordinate
 annotation.title = "THB : 33.67"
 annotation.subtitle = "$00.00"
 
 }
 }
 }
 
 //MARK : Extension for MKMapViewDelegate
 
 extension CurrencyMapViewController: MKMapViewDelegate {
 
 func saveUserRegion() {
 let mapRegion = [
 "latitude" : currencyMapView.region.center.latitude,
 "longitude" : currencyMapView.region.center.longitude,
 "latitudeDelta" : currencyMapView.region.span.latitudeDelta,
 "longitudeDelta" : currencyMapView.region.span.longitudeDelta
 ]
 UserDefaults.standard.set(mapRegion, forKey: userDefaultRegionKey)
 }
 
 //When mapView changed, update and save user last region.
 func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
 self.saveUserRegion()
 }
 
 //When mapView selected, set locationAnnotation
 func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
 guard let _ = view.annotation else {
 return
 }
 self.locationAnnotation = view.annotation as? MKPointAnnotation
 }
 
 //Using a reused pin to show on the mapView
 func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
 let reuseId = "pin"
 var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
 
 let geoPos = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
 CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
 }
 if pinView == nil {
 pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
 pinView!.canShowCallout = true
 pinView!.pinTintColor = .brown
 pinView!.rightCalloutAccessoryView = UIButton(type: .close)
 } else {
 pinView!.annotation = annotation
 }
 return pinView
 }
 }
 
 
 https://stackoverflow.com/questions/40214778/how-to-show-multiple-lines-in-mkannotation-with-autolayout
 
 func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
 
 let identifier = "MyPin"
 
 if annotation.isKindOfClass(MKUserLocation) {
 return nil
 }
 
 var annotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
 
 if annotationView == nil {
 
 annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
 annotationView?.canShowCallout = true
 
 let label1 = UILabel(frame: CGRectMake(0, 0, 200, 21))
 label1.text = "Some text1 some text2 some text2 some text2 some text2 some text2 some text2"
 label1.numberOfLines = 0
 annotationView!.detailCalloutAccessoryView = label1;
 
 let width = NSLayoutConstraint(item: label1, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 200)
 label1.addConstraint(width)
 
 
 let height = NSLayoutConstraint(item: label1, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 90)
 label1.addConstraint(height)
 
 
 
 } else {
 annotationView!.annotation = annotation
 }
 return annotationView
 }
 
 
 }
 
 */


//}

/* NOTE
 
 //______________________________________________________________________________________
 
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
 
 */
