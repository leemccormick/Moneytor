//
//  CurrencyMapViewController.swift
//  Moneytor
//
//  Created by Lee McCormick on 2/22/21.
//

import UIKit
import MapKit
import CoreLocation

class CurrencyMapViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let userDefaultRegionKey: String = "saveRegion"
    //var pin: PinLocation?
    var locationAnnotation: MKPointAnnotation!
    //    //var fetchedResultsController: NSFetchedResultsController<PinLocation>!
    //    var resultsCurrencyPair: CurrencyPair?
    var targetCountryName: String = ""
    var targetCode: String = ""
    var resultCovert: String = ""
    var rateInString: String = ""
    var baseCode: String = ""
    var totalBalanceInString: String = ""
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    
    var baseCodeForUserDefault = UserDefaults.standard.string(forKey: "baseCode")

    
    
    //MARK : LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        //getPersistedLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //deleteButton.isEnabled = false
        reloadLocationPins()
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(
          minCenterCoordinateDistance: 1000000,
          maxCenterCoordinateDistance: 1000000000)
       
        mapView.isZoomEnabled = true
    }
    
    
    
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .ended {
            let locationCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            userGeoCoordination(from: locationCoordinate)
        }
        
    }
    
    @IBAction func userLocationButtonTapped(_ sender: Any) {
    
        getLocation()
    
    }
    
    // MARK: - Helper Fuctions
    
    
    func userGeoCoordination(from coordinate: CLLocationCoordinate2D) {
        let geoPos = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let annotation = MKPointAnnotation()
        CLGeocoder().reverseGeocodeLocation(geoPos) {(placemarks, error) in
            guard (placemarks?.first) != nil else {return}
            
            annotation.coordinate = coordinate
            self.locationForPin(annotation)
        }
    }
    
    func locationForPin(_ annotation: MKPointAnnotation) {
        let location = PinLocation(context: CoreDataStack.shared.context)
        location.date = Date()
        location.latitude = annotation.coordinate.latitude
        location.longitude = annotation.coordinate.longitude
        let locationPin = LocationPin(pin: location)
        self.mapView.addAnnotation(locationPin)
        CoreDataStack.shared.saveContext()
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
    
    
    
    
    func presentConvertResultsToUser(titleAlert: String, messageAlert: String, targetCode: String, baseCode: String, countryName: String, rateInString: String) {
        let alertController = UIAlertController(title: titleAlert, message: messageAlert, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Done", style: .cancel)
        let calculationAction = UIAlertAction(title: "Convert Again", style: .default) { (action) in
            self.presentAlertToCalculateCurrency(targetCode: targetCode, baseCode: baseCode, countryName: countryName, rateInString: rateInString)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(calculationAction)
        present(alertController, animated: true)
    }
    
    
    func presentAlertToCalculateCurrency(targetCode: String, baseCode: String, countryName: String, rateInString: String) {
        
        // var dict: [String:Double] = [:]
        let baseCountry = CurrencyController.shared.findCountryNameByCurrencyCode(baseCode)
        let alertController = UIAlertController(title: "Currency Converter \n\(targetCode) <==> \(baseCode)",
                                                message: "Let's convert currency \nFrom \(countryName) To \(baseCountry)" ,preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Convert amount From \(targetCode) to \(baseCode)..."
            textField.keyboardAppearance = .dark
            textField.keyboardType = .decimalPad
        }
        
        
        // Calculate here
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let calculationAction = UIAlertAction(title: "Convert", style: .default) { (action) in
            guard let amount = alertController.textFields?.first?.text,
                  !amount.isEmpty else {return}
            let doubleRate = Double(rateInString)
            let doubleAmount = Double(amount)
            let totalAmountInBaseCurrency = doubleAmount! / doubleRate!
            let totalAmountInBaseCurrencyString = AmountFormatter.twoDecimalPlaces(num: totalAmountInBaseCurrency)
            // dict = [targetCode : amount ?? "0.0",
            //  baseCode : totalAmountInTargetCurrencyString ?? "0.0"]
       
            self.presentConvertResultsToUser(titleAlert: "\(countryName) Currency Converter!", messageAlert: "\(targetCode) :  \(amount) \n<==> \n\(baseCode) : \(totalAmountInBaseCurrencyString)", targetCode: targetCode, baseCode: baseCode, countryName: countryName, rateInString: rateInString)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(calculationAction)
        present(alertController, animated: true)
        
        // return dict
    }
    
    
    
    
    func presentAlertToCurrencyDetail(countryName: String, targetCode: String, resultCovert: String, rateInString: String,baseCode : String, totalString: String) {
        
        let alertController = UIAlertController(title: "Country Name : \(countryName)",
                                                message: "Currency Code: \(targetCode) \nRate : \(rateInString) \(targetCode) <==> 1.00 \(baseCode) \nBalance in \(baseCode): \(totalString) \nBalance in \(targetCode): \(resultCovert)", preferredStyle: .actionSheet)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        let calculationAction = UIAlertAction(title: "Converter", style: .default) { (action) in
            print("curreny converter")
            self.presentAlertToCalculateCurrency(targetCode: targetCode, baseCode: baseCode, countryName: countryName, rateInString: rateInString)
            
        }
        alertController.addAction(dismissAction)
        alertController.addAction(calculationAction)
        present(alertController, animated: true)
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
    
    //______________________________________________________________________________________
    
    
    //Using a reused pin to show on the mapView
    func mapViewCurrencyConverter(annotation: MKAnnotation) {
        
        let pinAnnotation = annotation as! LocationPin
        let geoPos = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
       
        //let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 8, longitudinalMeters: 8)
         // mapView.setRegion(coordinateRegion, animated: true)
        
        CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            guard let countryName = placemark.country else {return}
            let selectedCurrencyCode = CurrencyController.shared.findCurrencyCodeByCountyName(countryName)
            guard let selectedCode = selectedCurrencyCode else {return}
            TotalController.shared.calculateTotalBalance()
            let totalAmountInString = AmountFormatter.twoDecimalPlaces(num: TotalController.shared.totalBalance)
            
            ExchangeRateAPIController.fetchCurrencyPairConverter(targetCode: selectedCode, amount: totalAmountInString) { (results) in
                DispatchQueue.main.async {
                    switch results {
                    case .success(let currencyPair):
                        
                        
                        let targetCode = currencyPair.targetCoutryCode
                        let resultCovert = AmountFormatter.twoDecimalPlaces(num: currencyPair.convertResult)
                        let rateInString =  AmountFormatter.twoDecimalPlaces(num:currencyPair.rate)
                        let baseCode = currencyPair.baseCountryCode
                        
                        pinAnnotation.title = "Balance in \(countryName) : \(resultCovert)"
                        pinAnnotation.subtitle =  "Rate : \(rateInString) \(targetCode) <==> 1.00 \(baseCode)"
                        
                        
                        
                    // self.presentAlertToCurrencyDetail(countryName: self.targetCountryName, targetCode: targetCode, resultCovert: resultCovert, rateInString: rateInString, baseCode: baseCode, totalString: self.totalBalanceInString)
                    
                    //                        self.targetCountryName = countryName
                    //                        self.targetCode = targetCode
                    //                        self.resultCovert = resultCovert
                    //                        self.rateInString = rateInString
                    //                        self.baseCode = baseCode
                    //                        self.totalBalanceInString = totalAmountInString
                    //
                    case .failure(let error):
                        TotalController.shared.calculateTotalBalance()
                        pinAnnotation.title = "Total Balance : \(TotalController.shared.totalBalance)"
                        pinAnnotation.subtitle =  "Unable to calculate balance in \(countryName) currency"
                        
                        
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }
    
    //______________________________________________________________________________________
    
    
    //Using a reused pin to show on the mapView
    func mapViewCurrencyConverterAndAlertBy(annotation: MKAnnotation) {
        //l//et coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
          //mapView.setRegion(coordinateRegion, animated: true)
        let geoPos = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            guard let countryName = placemark.country else {return}
            let selectedCurrencyCode = CurrencyController.shared.findCurrencyCodeByCountyName(countryName)
            guard let selectedCode = selectedCurrencyCode else {return}
            TotalController.shared.calculateTotalBalance()
            let totalAmountInString = AmountFormatter.twoDecimalPlaces(num: TotalController.shared.totalBalance)
            
            ExchangeRateAPIController.fetchCurrencyPairConverter(targetCode: selectedCode, amount: totalAmountInString) { (results) in
                DispatchQueue.main.async {
                    switch results {
                    case .success(let currencyPair):
                        
                        let targetCode = currencyPair.targetCoutryCode
                        let resultCovert = AmountFormatter.twoDecimalPlaces(num: currencyPair.convertResult)
                        let rateInString =  AmountFormatter.twoDecimalPlaces(num:currencyPair.rate)
                        let baseCode = currencyPair.baseCountryCode
                        
                        self.presentAlertToCurrencyDetail(countryName: countryName, targetCode: targetCode, resultCovert: resultCovert, rateInString: rateInString, baseCode: baseCode, totalString: totalAmountInString)
                    
                    case .failure(let error):
                        TotalController.shared.calculateTotalBalance()
                        
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }
    
    //______________________________________________________________________________________
    
    
    //Using a reused pin to show on the mapView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        mapViewCurrencyConverter(annotation: annotation)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .mtTextLightBrown
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            
            pinView!.annotation = annotation
            pinView?.reloadInputViews()
        }
        
        
        return pinView
    }
   
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        guard let _ = view.annotation else {return}
        
        
        if let annotation = view.annotation as? MKPointAnnotation{
            
            mapViewCurrencyConverterAndAlertBy(annotation: annotation)
            

        }
        
    }
    
    
    
    
}


extension CurrencyMapViewController {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first {
            self.locationManager.stopUpdatingLocation()
            geoCoder.reverseGeocodeLocation(currentLocation) { [weak self] (placemarks, error) in
                guard let currentLocPlacemark = placemarks?.first else {return}
                guard let userCountryName = currentLocPlacemark.country else {return}
                
                
             //   UserDefaults.standard.setValue(userCountryName, forKey: "countryCode")
                
                print("got location \(userCountryName)")
                
                let baseCode = CurrencyController.shared.findCurrencyCodeByCountyName(userCountryName)
                
                if let baseCode = baseCode {
                    UserDefaults.standard.setValue(baseCode, forKey: "baseCode")

                    print("----------------- UserDefaults:: \(UserDefaults.standard.string(forKey: "baseCode"))-----------------")
                
                self?.presentLocationUpdatedAlert(userContryName: userCountryName, baseCode: baseCode)
                } else {
                    self?.presentErrorToUser(titleAlert: "Unable to find your current location!", messageAlert: "Currency Converter is now calculated base on USD.")
                }

            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to get location")
    }
    
    func getLocation() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyReduced
            locationManager.requestLocation()
        } else {
            print("error")
        }
    }
    
    func presentLocationUpdatedAlert(userContryName: String, baseCode: String) {
        let alertController = UIAlertController(title: "Current Country is\n\"\(userContryName)\"!", message: "Currency Converter is now calculated base on \(baseCode)", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
    
    
}

