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
    var resultsCurrencyPair: CurrencyPair? //{
    //        didSet {
    //            updatePinView(pinAnnotation: <#T##LocationPin#>)
    //        }
    //    }
    var targetCountryName: String?
    var targetCode: String?
    var resultCovert: String?
    var rateInString: String?
    var baseCode: String?
    
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
            
            
            guard let targetCountryName = placemark.country else {return}
            
            self.calculatePairCurrency(selectedCountryName: targetCountryName)
            
            
            
            
            annotation.title = "Balance in \(targetCountryName ) : \(self.resultCovert ?? "")"
            annotation.subtitle =  "Today Rate :\(self.targetCode ?? "")  \(self.rateInString ?? "")"
            annotation.coordinate = coordinate
            
            
            
            
            self.locationForPin(annotation)
        }
    }
    
    func locationForPin(_ annotation: MKPointAnnotation) {
        let location = PinLocation(context: CoreDataStack.shared.context)
        location.date = Date()
        location.latitude = annotation.coordinate.latitude
        location.longitude = annotation.coordinate.longitude
        
        
        //do {
        
        let locationPin = LocationPin(pin: location)
        self.mapView.addAnnotation(locationPin)
        CoreDataStack.shared.saveContext()
        
        
        // } catch {
        //   print(error.localizedDescription)
        //}
        
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
    
    func calculatePairCurrency(selectedCountryName: String) {
        print("-----calculatePairCurrency--------------- selectedCountryName: \(selectedCountryName) in \(#function) : ----------------------------\n\n\n\n\n\n\n)")
        let selectedCurrencyCode = CurrencyController.shared.findCurrencyCodeByCountyName(selectedCountryName)
        guard let selectedCode = selectedCurrencyCode else {return}
        TotalController.shared.calculateTotalBalance()
        let totalAmountInString = AmountFormatter.twoDecimalPlaces(num: TotalController.shared.totalBalance)
        
        ExchangeRateAPIController.fetchCurrencyPairConverter(baseCode: "USD", targetCode: selectedCode, amount: totalAmountInString) { (results) in
            DispatchQueue.main.async {
                switch results {
                case .success(let currencyPair):
                    self.resultsCurrencyPair = currencyPair
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        guard let results = resultsCurrencyPair else {return}
        
        targetCode = results.targetCoutryCode
        resultCovert = AmountFormatter.twoDecimalPlaces(num: results.convertResult)
        rateInString =  AmountFormatter.twoDecimalPlaces(num:results.rate)
        baseCode = results.baseCountryCode
        // let selectedCountryName = CurrencyController.shared.findCountryNameByCurrencyCode(results.targetCoutryCode)//
        print("-------------------- resultsCurrencyPair: \(resultsCurrencyPair?.targetCoutryCode) in \(#function) : ----------------------------\n)")
        
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
            self.targetCountryName = countryName
            print("\n\n\ntarget PlackMArk saved \(String(describing: self.targetCountryName)) \n\n\n\n\n\n\n\n")
            
            let selectedCurrencyCode = CurrencyController.shared.findCurrencyCodeByCountyName(countryName)
            guard let selectedCode = selectedCurrencyCode else {return}
            TotalController.shared.calculateTotalBalance()
            let totalAmountInString = AmountFormatter.twoDecimalPlaces(num: TotalController.shared.totalBalance)
            
            ExchangeRateAPIController.fetchCurrencyPairConverter(baseCode: "USD", targetCode: selectedCode, amount: totalAmountInString) { (results) in
                DispatchQueue.main.async {
                    switch results {
                    case .success(let currencyPair):
                        self.resultsCurrencyPair = currencyPair
                        
                        let targetCode = currencyPair.targetCoutryCode
                        let resultCovert = AmountFormatter.twoDecimalPlaces(num: currencyPair.convertResult)
                        let rateInString =  AmountFormatter.twoDecimalPlaces(num:currencyPair.rate)
                        let baseCode = currencyPair.baseCountryCode
                        
                        pinAnnotation.title = "Balance in \(countryName) : \(resultCovert)"
                        pinAnnotation.subtitle =  "Today Rate : \(rateInString) \(targetCode) = 1 \(baseCode)"
                        
                    case .failure(let error):
                        TotalController.shared.calculateTotalBalance()
                        pinAnnotation.title = "Total Balance : \(TotalController.shared.totalBalance)"
                        pinAnnotation.subtitle =  "Unable to calculate balance in \(countryName) currency"
                        
                        
                        print(error.localizedDescription)
                    }
                }
            }
        }
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            
            pinView!.annotation = annotation
            pinView?.reloadInputViews()
        }
        
        
        return pinView
    }
    //            self.calculatePairCurrency(selectedCountryName: self.targetCountryName ?? "THB")
    //            if let targetCountryName = self.targetCountryName,
    //               let resultCovert = self.resultCovert,
    //               let rateInString = self.rateInString,
    //               let targetCode = self.targetCode,
    //               let baseCode = self.baseCode {
    //
    //                    pinAnnotation.title = "Balance in \(targetCountryName) : \(resultCovert)"
    //                    pinAnnotation.subtitle =  "Today Rate : \(rateInString) \(targetCode) = 1 \(baseCode)"
    //                   } else {
    //                    self.calculatePairCurrency(selectedCountryName: countryName)
    ////                    pinAnnotation.title = "Balance in \(self.self.targetCountryName) : \(self.self.resultCovert)"
    ////                    pinAnnotation.subtitle =  "=========================Today Rate : \(self.rateInString) \(self.targetCode) = 1 \(self.baseCode)"
    //                   }
    //                    //
    //        }
    //        pinAnnotation.title = "Balance in \(targetCountryName) : \(resultCovert)"
    //        pinAnnotation.subtitle =  "Today Rate : \(rateInString) \(targetCode) = 1 \(baseCode)"
    //        //
    //        pinAnnotation.title = "Balance in \(targetCountryName ?? "") : \(resultCovert ?? "")."
    //       pinAnnotation.subtitle =  "Today \(targetCode ?? "") Rate : \(rateInString ?? "") per 1 \(baseCode ?? "")."
    // annotation.title =
    
    // calculatePairCurrency(selectedCountryName: targetCountryName ?? "THB")
    // guard let results = resultsCurrencyPair else {return MKAnnotationView()}
    //
    //                     let selectedCode = results.targetCoutryCode
    //                     let resultCovert = AmountFormatter.twoDecimalPlaces(num: results.convertResult)
    //                     let rate =  AmountFormatter.twoDecimalPlaces(num:results.rate)
    //                     let baseCode = results.baseCountryCode
    //                     let selectedCountryName = CurrencyController.shared.findCountryNameByCurrencyCode(results.targetCoutryCode)
    //                    guard let targetCountryName = targetCountryName,
    //                          let resultCovert = resultCovert,
    //                          let targetCode = targetCode,
    //                          let rateInString = rateInString,
    //                          let baseCode = baseCode else {return nil}
    
    
    
    
    
    //When callout on Pit, save LocationPin and performSegue to PhotoAblumVC
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        guard let _ = view.annotation else {return}
        
        
        if let annotation = view.annotation as? MKPointAnnotation{
            
            
            print("\n\n\n\n----------------- annotation:: \(annotation)----------------- in \(#function)")
            
        }
        
    }
    
}



