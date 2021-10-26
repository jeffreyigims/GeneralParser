import UIKit
import Alamofire

// Our structs, models in MVVM
struct Repositories: Codable {
  let items: [Repository]
  
  enum CodingKeys: String, CodingKey {
    case items
  }
}

struct Repository: Codable, Identifiable {
  let id: Int
  let name: String
  let htmlURL: String
  let itemDescription: String?
  
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case htmlURL = "html_url"
    case itemDescription = "description"
  }
}

// We turn each request we make into a generic struct
struct Request<T> {
  let method: HTTPMethod
  let params: Parameters
  let exten: String
  let success: ((AFDataResponse<T>) -> ())
  let failure: ((AFDataResponse<T>) -> ())
}

// Our ViewModel, the view model in MVVM
class ViewModel {
  
  // Headers can be useful when passing in authentication
  var headers: HTTPHeaders? = HTTPHeaders()
  /*
     Note how we are taking the URL we used in lab, and splitting it into a new URL, an
     extension, and a dictionary of paramaters to make it as generic as possible
   */
  var URL: String = "https://api.github.com"
  /*
     The value we are updating with our asynchronous call, may be useful
     to make it a published variable and use in our views
   */
  var repositories: [Repository] = [Repository]()
  
  // Takes a generic request struct, constructs a valid Almofire request, and makes request
  func request<T>(req: Request<T>) where T : Decodable {
    AF.request(URL + req.exten, method: req.method, parameters: req.params)
      .validate()
      .responseDecodable {
        ( response: AFDataResponse<T>) in
        switch response.result {
        case .success:
          req.success(response)
        case .failure:
          req.failure(response)
        }
      }
  }
  
  // Asynchronous call to fetch and update our repositories variable
  func getRepositories() {
    
    // Paramters, our old arguments
    let params: Parameters = [
      "sort": "stars",
      "order": "desc",
      "q": "language:swift"
    ]
    
    // Concatenated with the global URL in our request
    let exten: String = "/search/repositories"
    
    /*
       Note how we pass two closures to our request, so we can handle
       different kinds of repsonses
     */
    let success: (AFDataResponse<Repositories>) -> () = { (res) in
      self.repositories = res.value?.items ?? [Repository]()
      print("We got our repositories!")
      print(self.repositories)
    }
    let failure: (AFDataResponse<Repositories>) -> () = { (res) in
      print("Could not get a valid response with \(res)")
    }
    
    // Create an instance of our struct
    let req: Request = Request(method: .get, params: params, exten: exten, success: success, failure: failure)
    // Make asynchronous request with our struct
    request(req: req)
  }
}

// Make instance of ViewModel and fetch our repositories
let viewModel: ViewModel = ViewModel()
viewModel.getRepositories()

