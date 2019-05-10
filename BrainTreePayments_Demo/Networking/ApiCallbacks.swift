

import UIKit

protocol ApiCallbacks {
    func onHttpResponse(request: ApiRequest, data: Any)
    func onHttpError(error: String)
}
