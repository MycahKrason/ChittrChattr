//
//  LocationListViewController.swift
//  ChittrChattr
//
//  Created by Mycah on 4/7/18.
//  Copyright © 2018 Mycah. All rights reserved.
//
//  ****** Be Sure to Edit the info.plist file to include
//  ****** ~ Privacy - Location When In Use Usage Description
//  ****** ~ Privacy - Location Usage Description

import UIKit
import CoreLocation
import GooglePlaces

class LocationListViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //Setting Google places stuff
    var placesClient: GMSPlacesClient!
    var likeHoodList: GMSPlaceLikelihoodList?
    
    @IBOutlet weak var tableView: UITableView!
    
    //Setting Location Manager
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var infoButtonDisplay: UIButton!
    @IBOutlet weak var backButtonDisplay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Use this method so that the location information will be uploaded everytime this View is opened
    override func viewWillAppear(_ animated: Bool) {
        
        //Set Up LocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        getAuthorized()
        
        //Set up Google Places
        placesClient = GMSPlacesClient.shared()
        self.nearbyPlaces()
        
        //Set up Table View
        tableView.dataSource = self
        tableView.delegate = self
        
        //set image size aspect
        backButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        backButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        //set image size aspect
        infoButtonDisplay.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        infoButtonDisplay.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)

        //Register the custom cell
        tableView.register(UINib(nibName: "CustomLocationListCell", bundle: nil), forCellReuseIdentifier: "customLocationListCell")
    }
    
    //*****************************************
    //****** Location Delegate Functions ******
    //*****************************************
    
    //make sure that we are authorized - then update location
    func getAuthorized(){
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationManager.startUpdatingLocation()
                self.nearbyPlaces()
            }
        } else {
            print("Location services are not enabled")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // The user has given permission to your app
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            self.nearbyPlaces()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Get Location
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            
            //Stop updating the location so you don't kill the User's battery
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        //Let the User know that there has been an error... if you feel like it
    }
    
    
    //***********************
    //MARK: Google Places API
    //***********************
    
    func nearbyPlaces() {
        if placesClient != nil{
            placesClient.currentPlace(callback: { (placeLikelihoodList, error) in
                if let error = error {
                    print("Pick Place error: \(error.localizedDescription)")
                    return
                }
                
                if let placeLikelihoodList = placeLikelihoodList {
                    self.likeHoodList = placeLikelihoodList
                    self.tableView.reloadData()
                }
            })
        }
        
    }
    
    //***********************
    //MARK: Table Information
    //***********************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if likeHoodList != nil {
            
            //Limit the amount of possibilities
            if (likeHoodList?.likelihoods.count)! < 10{
                return (likeHoodList?.likelihoods.count)!
            }else{
                return 10
            }
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customLocationListCell", for: indexPath) as! CustomLocationListCell
        
        //dont highlight
        cell.selectionStyle = .none
        
        //Get Place Name
        let place = likeHoodList?.likelihoods[indexPath.row].place //this is a GMSPlace object
        
        //Display Place Name
        cell.locationNameLabel.text = place?.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "LocationToChatRoom", sender: self)
        
    }
    
    //Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocationToChatRoom"{
            
            //Get the indexPath so we know what was clicked
            if let indexPath = tableView.indexPathForSelectedRow{
                
                //Get the destination view controller
                let destVC = segue.destination as! ChatRoomViewController
                
                //Get Place Name
                let place = likeHoodList?.likelihoods[indexPath.row].place //this is a GMSPlace object
                //Filter the address because Firebase hates "#"
                var filteredName = place?.name
                filteredName = filteredName!.replacingOccurrences(of: "#", with: "num: ", options: NSString.CompareOptions.literal, range: nil)
                
                //Get Address
                var address = likeHoodList?.likelihoods[indexPath.row].place.formattedAddress
                //Filter the address because Firebase hates "#"
                address = address!.replacingOccurrences(of: "#", with: "num: ", options: NSString.CompareOptions.literal, range: nil)
                
                //Testing the address and name
                print("\n",filteredName!," - ",address!)
                
                //Send things to the destVC
                destVC.chatRoomAddress = address
                destVC.chatRoomName = filteredName
                
            }
            
        }else if segue.identifier == "locationsToInfoModal"{
            
            let destVC = segue.destination as! InfoModalViewController
            destVC.receivedInfo = "Click on your location to talk to other people there"
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

