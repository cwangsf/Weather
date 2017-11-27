
import UIKit
import Alamofire

@available(iOS 11.0, *)
class ViewController: UIViewController {

    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var mainDescription: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var weather = DataManager.lastCityWeather()
    var cities = [City]()
    var filteredCities = [City]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        spinner.startAnimating()
        DataManager.cityList() { [weak self] cities in
            self?.cities = cities
            DispatchQueue.main.async {[weak self] in
                print("Finish city data loading")
                self?.spinner.stopAnimating()
            }
        }
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search City" // In general, no hard coded string is the best. In Enterprised appliacation, these will be centralized, maybe also localized 
       
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        var lastCityId = "5391959"
        if let cityId = UserDefaults.standard.string(forKey: "lastCityId") {
            lastCityId = cityId
            print("Get the last city id: \(lastCityId)")
        }
        DataManager.fetchWeatherDataByCityId(city: lastCityId, completion: { [weak self] weather in
            self?.weather = weather
            self?.updateUIComponents()
        })

        searchController.searchBar.delegate = self

    }

    func updateUIComponents() {
        DispatchQueue.main.async {[weak self] in
            guard let strongself = self,
                let updatedWeather = self?.weather,
                let weatherlist = self?.weather?.weatherInfo else { return }
            strongself.cityName.text = updatedWeather.cityName
            let fahrenheit = (updatedWeather.mainInfo?.temp)! * 9 / 5 - 459.67
            strongself.temperature.text = String(format:"%.2f",fahrenheit) + " °F"
  
            strongself.mainDescription.text = weatherlist[0].main
            strongself.tableView.reloadData()
            strongself.searchController.searchBar.text = ""
        }
        
        if let imageName = weather?.weatherInfo?[0].icon {
            
            DataManager.downloadImage(withName: imageName) { [weak self](image) in
                guard image != nil else { return }
                DispatchQueue.main.async {[weak self] in
                    self?.weatherIcon.image = image
                }
            }
        }
    }
}
// MARK: - UISearchBar Delegate
@available(iOS 11.0, *)
extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let text = searchBar.text else {return}
        filterContentForSearchText(text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredCities.removeAll()
        tableView.reloadData()
        tableView.isHidden = true
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
@available(iOS 11.0, *)
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredCities.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var city = cities[indexPath.row]
        if isFiltering() {
            city = filteredCities[indexPath.row]
        } 
        cell.textLabel!.text = city.name
        cell.detailTextLabel!.text = city.country
        return cell
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = filteredCities[indexPath.row]
        let cityIdString = String(describing:city.id ?? 0)
        DataManager.fetchWeatherDataByCityId(city:cityIdString, completion: {[weak self] (weather) in
            guard let strongself = self else { return }
            strongself.weather = weather
            self?.filteredCities.removeAll()
            UserDefaults.standard.set(cityIdString, forKey:"lastCityId")
            print("Saved last city id: \(cityIdString)")
            strongself.updateUIComponents()
        })
    }
}

// MARK: - UISearchResultsUpdating Delegate
@available(iOS 11.0, *)
extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        if cities.count > 0 {
            tableView.isHidden = false
            
            filteredCities = cities.filter({( city : City) -> Bool in
                return (city.name?.lowercased().contains(searchText.lowercased()))!
            })
            
            tableView.reloadData()
        }
    }
}

