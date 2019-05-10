

import UIKit

enum ApiParam {
    case text(key: String, value: String)
    case data(key: String, filename: String, type: String, value: Data)
    case anyValue(key: String, value: Any)
}
