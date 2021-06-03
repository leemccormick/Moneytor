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
    
    // MARK: - Properties
    let userDefaultRegionKey: String = "saveRegion"
    var locationAnnotation: MKPointAnnotation!
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    
    //MARK : LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
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
    
    @IBAction func deletedAllPinsButtonTapped(_ sender: Any) {
        presentAlertToDeleteAllPins()
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
        LocationPinController.shared.reloadLocationPins()
        let pins = LocationPinController.shared.loctionPins
        self.mapView.addAnnotations(pins.map {pin in LocationPin(pin: pin)})
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
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

// MARK: - MKMapViewDelegate
extension CurrencyMapViewController: MKMapViewDelegate {
    
    func mapViewCurrencyConverter(annotation: MKAnnotation) {
        let pinAnnotation = annotation as! LocationPin
        let geoPos = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            guard let countryName = placemark.country else {return}
            let selectedCurrencyCode = CurrencyController.shared.findCurrencyCodeByCountyName(countryName)
            guard let selectedCode = selectedCurrencyCode else {return}
            TotalController.shared.calculateTotalBalanceByMonthly()
            var totalAmountInString = AmountFormatter.twoDecimalPlaces(num: TotalController.shared.totalBalanceMontly)
            
            if (Double(totalAmountInString) ?? 0.0) <= 0 {
                totalAmountInString = "1"
            }
            
            ExchangeRateAPIController.fetchCurrencyPairConverter(targetCode: selectedCode, amount: totalAmountInString) { (results) in
                DispatchQueue.main.async {
                    switch results {
                    case .success(let currencyPair):
                        let targetCode = currencyPair.targetCoutryCode
                    
                       // let resultCovert = AmountFormatter.twoDecimalPlaces(num: currencyPair.convertResult)
                        let rateInString =  AmountFormatter.twoDecimalPlaces(num:currencyPair.rate)
                        let baseCode = currencyPair.baseCountryCode
                        let targetCountryName = CurrencyController.shared.findCountryNameByCurrencyCode(targetCode)
                       // pinAnnotation.title = "Balance in \(countryName) : \(resultCovert)"
                        pinAnnotation.title =  "Currency Rate: \(rateInString) \(targetCode) == 1.00 \(baseCode)"
                        
                        pinAnnotation.subtitle =  "Click! for converter and detail in \(targetCountryName)"
                        //pinAnnotation.subtitle =  "Click! for currency converter and more detail of your money in \(targetCountryName)"
                    case .failure(let error):
                        TotalController.shared.calculateTotalBalance()
                        pinAnnotation.title = "Total Monthly Balance : \(TotalController.shared.totalBalanceMontly)"
                        pinAnnotation.subtitle =  "Unable to calculate balance in \(countryName) currency, please check your internet connection!"
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func mapViewCurrencyConverterAndAlertBy(annotation: MKAnnotation) {
        let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(coordinateRegion, animated: true)
        let geoPos = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(geoPos) { (placemarks, error) in
            guard let placemark = placemarks?.first else { return }
            guard let countryName = placemark.country else {return}
            let selectedCurrencyCode = CurrencyController.shared.findCurrencyCodeByCountyName(countryName)
            guard let selectedCode = selectedCurrencyCode else {return}
            TotalController.shared.calculateTotalBalance()
          //  let totalAmountInString = AmountFormatter.twoDecimalPlaces(num: TotalController.shared.totalBalance)
            
            var totalAmountInString = AmountFormatter.twoDecimalPlaces(num: TotalController.shared.totalBalanceMontly)
            
            if (Double(totalAmountInString) ?? 0.0) <= 0 {
                totalAmountInString = "1"
            }
            
            
            ExchangeRateAPIController.fetchCurrencyPairConverter(targetCode: selectedCode, amount: totalAmountInString) { [weak self] (results) in
                DispatchQueue.main.async {
                    switch results {
                    case .success(let currencyPair):
                        let targetCode = currencyPair.targetCoutryCode
                        let resultCovert = AmountFormatter.twoDecimalPlaces(num: currencyPair.convertResult)
                        let rateInString =  AmountFormatter.twoDecimalPlaces(num:currencyPair.rate)
                        let baseCode = currencyPair.baseCountryCode
                        self?.presentAlertToCurrencyDetail(countryName: countryName, targetCode: targetCode, resultCovert: resultCovert, rateInString: rateInString, baseCode: baseCode, totalString: totalAmountInString)
                    case .failure(let error):
                        TotalController.shared.calculateTotalBalance()
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        self.saveUserRegion()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let _ = view.annotation else {
            return
        }
        self.locationAnnotation = view.annotation as? MKPointAnnotation
    }
    
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

// MARK: - LocationManager
extension CurrencyMapViewController {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first {
            self.locationManager.stopUpdatingLocation()
            geoCoder.reverseGeocodeLocation(currentLocation) { [weak self] (placemarks, error) in
                guard let currentLocPlacemark = placemarks?.first else {return}
                guard let userCountryName = currentLocPlacemark.country else {return}
                
                print("got location \(userCountryName)")
                
                let baseCode = CurrencyController.shared.findCurrencyCodeByCountyName(userCountryName)
                if let baseCode = baseCode {
                    UserDefaults.standard.setValue(baseCode, forKey: "baseCode")
                    print("----------------- UserDefaults:: \(String(describing: UserDefaults.standard.string(forKey: "baseCode")))-----------------")
                    self?.presentLocationUpdatedAlert(userContryName: userCountryName, baseCode: baseCode)
                } else {
                    self?.presentAlertToUser(titleAlert: "Unable to find your current location!", messageAlert: "Currency Converter is now calculated base on USD.")
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
        let alertController = UIAlertController(title: "Your Current Country is\n\"\(userContryName)\"", message: "Currency Converter is calculated based on your location. \nThis base currency for converter is \(baseCode).", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}

// MARK: - Currency AlertController
extension CurrencyMapViewController {
    func presentAlertToDeleteAllPins() {
        let alertController = UIAlertController(title: "Delete Pins!", message: "Are you sure to delete all annotation pins for this currency converter?", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let deletedAction = UIAlertAction(title: "Delete Pins", style: .destructive) { (action) in
            LocationPinController.shared.deleteAllPinLocation()
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(deletedAction)
        present(alertController, animated: true)
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
        
        let baseCountry = CurrencyController.shared.findCountryNameByCurrencyCode(baseCode)
        let alertController = UIAlertController(title: "Currency Converter \n\(targetCode) <==> \(baseCode)",
                                                message: "Let's convert currency \nFrom \(countryName) To \(baseCountry)!" ,preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter amount in \(targetCode) to convert..."
            textField.keyboardAppearance = .dark
            textField.keyboardType = .decimalPad
        }
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel)
        let calculationAction = UIAlertAction(title: "Convert", style: .default) { (action) in
            guard let amount = alertController.textFields?.first?.text,
                  !amount.isEmpty else {return}
            let doubleRate = Double(rateInString)
            let doubleAmount = Double(amount)
            let totalAmountInBaseCurrency = doubleAmount! / doubleRate!
            let totalAmountInBaseCurrencyString = AmountFormatter.twoDecimalPlaces(num: totalAmountInBaseCurrency)
            self.presentConvertResultsToUser(titleAlert: "\(countryName) Currency Converter!", messageAlert: "\(targetCode) :  \(amount) \n<==> \n\(baseCode) : \(totalAmountInBaseCurrencyString)", targetCode: targetCode, baseCode: baseCode, countryName: countryName, rateInString: rateInString)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(calculationAction)
        present(alertController, animated: true)
    }
    
    func presentAlertToCurrencyDetail(countryName: String, targetCode: String, resultCovert: String, rateInString: String,baseCode : String, totalString: String) {
        
        var alertController = UIAlertController()
        if totalString == "1" {
          //  let totalAmountInString = AmountFormatter.twoDecimalPlaces(num: TotalController.shared.totalBalanceMontly)
           alertController = UIAlertController(title: "Country Name : \(countryName)",
                                                    message: "Currency Code : \(targetCode) \nCurrency Rate : \(rateInString) \(targetCode) == 1.00 \(baseCode)", preferredStyle: .actionSheet)
        } else {
             let totalMonthlyIncome =  TotalController.shared.totalIncomeStringMontly
            let totalMonthlyExpense = TotalController.shared.totalExpenseStringMontly
            let targerMontlyIncome = (Double(rateInString) ?? 0.0) * TotalController.shared.totalIncomeMontly
            let targerMontlyIncomeTwoDecimal = AmountFormatter.twoDecimalPlaces(num: targerMontlyIncome)
            let targerMontlyExpense = (Double(rateInString) ?? 0.0) * TotalController.shared.totalExpenseMontly
            let targerMontlyExpenseTwoDecimal = AmountFormatter.twoDecimalPlaces(num: targerMontlyExpense)

            
          //  let targerMontlyExpense = AmountFormatter.twoDecimalPlaces(Double(rateInString) ?? 0.0) * TotalController.shared.totalIncomeMontly))
            
            alertController = UIAlertController(title: "Country Name : \(countryName)",
                                                    message: "Currency Code : \(targetCode) \nCurrency Rate : \(rateInString) \(targetCode) == 1.00 \(baseCode) \nMonthly Balance in \(baseCode) : \(totalString) \nMonthly Balance in \(targetCode): \(resultCovert) \nMonthly Income in \(baseCode) : \(totalMonthlyIncome) \nMonthly Income in \(targetCode) : \(targerMontlyIncomeTwoDecimal) \nMonthly Expense in \(baseCode) : \(totalMonthlyExpense) \nMonthly Expense in \(targetCode) : \(targerMontlyExpenseTwoDecimal) ", preferredStyle: .actionSheet)
        }
//        let alertController = UIAlertController(title: "Country Name : \(countryName)",
//                                                message: "Currency Code : \(targetCode) \nCurrency Rate : \(rateInString) \(targetCode) == 1.00 \(baseCode) \nMonthly Balance in \(baseCode) : \(totalString) \nMonthly Balance in \(targetCode): \(resultCovert)", preferredStyle: .actionSheet)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        let calculationAction = UIAlertAction(title: "Currency Converter", style: .default) { (action) in
            print("curreny converter")
            self.presentAlertToCalculateCurrency(targetCode: targetCode, baseCode: baseCode, countryName: countryName, rateInString: rateInString)
        }
        alertController.addAction(dismissAction)
        alertController.addAction(calculationAction)
        present(alertController, animated: true)
    }
}
