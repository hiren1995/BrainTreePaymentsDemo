
import UIKit

enum ApiRequest {
    
    case debitAPI(payment_method_nonce:String,amount:Float)
    
    var httpMethod: HttpMethods {
        switch self {
            
        case .debitAPI:
            return HttpMethods.POST

        }
    }
    
    var httpUrl: String {
        switch self {
        case .debitAPI:
            return "/pay.php"
        
        }
    }
    
    var contentType: ContentTypes {
        switch self {
        case .debitAPI:
            return ContentTypes.urlEncoded
        }
    }
    
    var httpHeaders: [Headers]{
        switch self {
        case .debitAPI:
           return []
   
        default:
            return []
        }
    }
    
    /*var keyValueParams: [String: Any]{
        switch self {
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .register(let user, let password):
            return ["firstname": user.firstname, "lastname":user.lastname, "email": user.email, "password": password, "password_confirmation": password, "confirm_success_url":""]
        case .forgotpassword(let email):
            return ["email": email, "confirm_success_url":""]
        }
    }*/
    
    var requestParams: [ApiParam]{
        switch self {
        case .debitAPI(let payment_method_nonce,let amount):
            return [ApiParam.anyValue(key: "payment_method_nonce", value: payment_method_nonce),ApiParam.anyValue(key: "amount", value: amount)]
        
        default:
            return []
            
        }
    }
    
    /*var data: Any{
        switch self {
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .register(let user, let password):
            return ["firstname": user.firstname, "lastname":user.lastname, "email": user.email, "password": password, "password_confirmation": password, "confirm_success_url":""]
        case .forgotpassword(let email):
            return ["email": email, "confirm_success_url":""]
        }
    }*/
    
    func parseResponseData(data: Data, httpResponse: HTTPURLResponse, apiCallbacks: ApiCallbacks ){
        switch self {
        case .debitAPI:
            DispatchQueue.main.async {
                apiCallbacks.onHttpResponse(request: self, data: data)
            }
        
        }
    }
    
    enum HttpMethods: String{
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    enum ContentTypes: String {
        case json = "application/json"
        case urlEncoded = "application/x-www-form-urlencoded"
        case multipart = "multipart/form-data;"
        
    }
    
    enum Headers {
        case accept(contentType: ContentTypes)
        case tokenType(token: String)
        case contentType(contentType: ContentTypes)
        case accessToken(token: String)
        case client(client: String)
        case expiry(expiry: String)
        case uid(uid: String)
        
        var key : String {
            switch self {
            case .accept:
                return "Accept"
            case .tokenType:
                return "Authorization"
            case .contentType:
                return "Content-Type"
            case .accessToken:
                return "access-token"
            case .client:
                return "client"
            case .expiry:
                return "expiry"
            case .uid:
                return "uid"
            }
        }
        
        var value: String {
            switch self {
            case .accept(let contentType), .contentType(let contentType):
                return contentType.rawValue
            case .tokenType(let token):
                return token
            case .accessToken(let accessToken):
                return accessToken
            case .client(let client):
                return client
            case .expiry(let expiry):
                return expiry
            case .uid(let uid):
                return uid
            }
        }
    }
    
    func createHttpRequest() -> URLRequest{
        
        let debug: Bool = true;
        
        
        //For GET method we will add text params as query string to url
        var queryitems = [URLQueryItem]()
        
        //For URL encode we will add only text params to body
        var keyValueParams = [String: Any]()

        for param in requestParams {
            
            switch param {
            case .text(let key, let value):
                
                print("key - \(key) && value - \(value)")
                
                queryitems.append(URLQueryItem(name: key, value: value))
                keyValueParams[key] = value
                
            case .anyValue(let key, let value):
                
                print("key - \(key) && value - \(value)")
                
                queryitems.append(URLQueryItem(name: key, value: "\(value)"))
                keyValueParams[key] = value
                
            default:
                if (debug) { debugPrint("Ignore non text params for keyValueParams") }
            }
        }
        
        /*for (key,value) in keyValueParams {
            if let keyvalue = value as? String {
                queryitems.append(URLQueryItem(name: key, value: keyvalue))
            }
        }*/
        
        
        //------- for live Server ----------//
        
//        let urlComponents = NSURLComponents()
//        urlComponents.scheme = ApiConfig.PROTOCOL
//        urlComponents.percentEncodedHost = ApiConfig.HOST
//        urlComponents.percentEncodedPath = ApiConfig.PATH + httpUrl

        let urlComponents = NSURLComponents()
        urlComponents.scheme = ApiConfig.PROTOCOL
        urlComponents.percentEncodedPath = ApiConfig.PATH + httpUrl

        
        
        if httpMethod == HttpMethods.GET {
            urlComponents.queryItems = queryitems
        }
        
        // This is a POST method, though we need to append a URL query item
//        switch self {
//        case .deleteZone, .deleteDevice, .setFirstTimePopupOpen, .deleteCustomerLocation, .deleteGateway, .deleteFamilyMember:
//            urlComponents.queryItems = queryitems
//            break
//        default:
//            break
//        }
        
        print(urlComponents.url!)
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        
        urlRequest.httpMethod = httpMethod.rawValue
        
        for header in httpHeaders {
            
            if debug { print("\(header.key) : \(header.value)") }
            
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        switch contentType {
            
        case ContentTypes.json:
            
            let headerContentType = Headers.contentType(contentType: .json)
            
            urlRequest.addValue(headerContentType.value, forHTTPHeaderField: headerContentType.key)
            
            if debug { debugPrint(headerContentType.key + " : "+headerContentType.value)}
            
            if keyValueParams.count > 0{
                
                print(keyValueParams)
                
                urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: keyValueParams, options: .prettyPrinted)
            }
        
        case ContentTypes.urlEncoded:
            
            let headerContentType = Headers.contentType(contentType: .urlEncoded)
            
            urlRequest.addValue(headerContentType.value, forHTTPHeaderField: headerContentType.key)
            
            if debug { debugPrint(headerContentType.key + " : "+headerContentType.value)}
            
            if !queryitems.isEmpty &&  httpMethod != HttpMethods.GET{
                
                let queryComponents = NSURLComponents()
                
                queryComponents.queryItems = queryitems
                
                //VISH 20180316 - Need to confirm if we need to encode any other characters. Not tested
                urlRequest.httpBody =  queryComponents.percentEncodedQuery!.data(using: String.Encoding.utf8)
            }
            
        case ContentTypes.multipart:
            
            let boundary = "*****" + UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased() + "*****"
            
            let headerContentType = Headers.contentType(contentType: .multipart)
            
            urlRequest.addValue(headerContentType.value + " boundary=" + boundary, forHTTPHeaderField: headerContentType.key)
            
            if debug { debugPrint(headerContentType.key + " : "+headerContentType.value+" boundary=" + boundary)}
            
            urlRequest.httpBody = createMultipartBody(boundary: boundary)
            
        }
        
        if debug { print("Body") }
        
        //if debug { print( String(data: urlRequest.httpBody!,encoding: String.Encoding.utf8)! ) }
        
        return urlRequest
        
    }
    
    func createMultipartBody(boundary: String) -> Data {
        
        let twoHyphen: String = "--"
        
        let crlf: String = "\r\n"
        
        var body = Data()
        
        for param in requestParams{
            
            //Start param
            body.append((twoHyphen+boundary+crlf).data(using: .utf8)!)
            
            switch param{
            case .text(let key, let value):
                    body.append(("Content-Disposition: form-data; name=\""+key+"\""+crlf+crlf).data(using: .utf8)!)
                    body.append(value.data(using: .utf8)!)
            case .data(let key, let filename, let type, let value):
                    body.append(("Content-Disposition: form-data; name=\"" + key + "\"; filename=\""+filename+"\""+crlf).data(using: .utf8)!)
                    body.append(("Content-Type: \(type)"+crlf+crlf).data(using: .utf8)!)
                    body.append(value)
                    body.append(crlf.data(using: .utf8)!)
            default:
                print("Not a Multipart type")
                break
            }
        }
        
        //End body
        body.append((twoHyphen+boundary+twoHyphen+twoHyphen).data(using: .utf8)!)
        
        return body
    }

}
