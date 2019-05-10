
import Foundation
import UIKit
import SVProgressHUD


class HttpManager{
    
    static let defaultManager = HttpManager()
    
    static var shared: HttpManager {
        return defaultManager
    }
    
    func executeHttpRequest(apiRequest: ApiRequest, apiCallbacks: ApiCallbacks){
        
        
        /*
        if Reachability.isConnectedToNetwork(){
            
            
        }else{
            
            apiCallbacks.onHttpError(error: "Device not Connected to Internet.")
        }
        */
        
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.clear)
        
        let datatask = URLSession.shared.dataTask(with: apiRequest.createHttpRequest()){ (responseData, response, responseError) in

            SVProgressHUD.dismiss()

            if responseError == nil {
                if let httpResponse = response as? HTTPURLResponse {

                    let statusCode = httpResponse.statusCode

                    print(statusCode)

                    if statusCode == 200 {

                        let dictResponse = responseData?.getDictionaryFromData()
                        print(dictResponse)
                        
                        if responseData != nil {
                        
                        apiRequest.parseResponseData(data: responseData!, httpResponse: httpResponse, apiCallbacks: apiCallbacks)

                        }else{

                        }
                    }
                    else if(statusCode == 403){
                        apiCallbacks.onHttpError(error: "serverFailedToRespond".localized())
                        print("Server Failed To Respond")
                    }
                    else{
                        
                        let dictResponse = responseData?.getDictionaryFromData()
                        print(dictResponse)
                        
                        if let message = dictResponse!["message"] as? String{
                            apiCallbacks.onHttpError(error: message)
                        }else{
                            apiCallbacks.onHttpError(error: "somethingWentWrong".localized())
                        }
                    }
                }
            }else{
                print("executeHttpRequest \(responseError)")
                DispatchQueue.main.async {
                    apiCallbacks.onHttpError(error: (responseError?.localizedDescription)!)
                }
            }
        }
        datatask.resume()

    }
    
}
