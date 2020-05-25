import Foundation
import UIKit
import AWSCore

class AmazonSigning{
    let kAmazonAccessID = ""
    let kAmazonAccessSecretKey = ""
    
    let kAmazonAssociateTag = ""
    let timestampFormatter: DateFormatter
    
    init() {
        timestampFormatter = DateFormatter()
        timestampFormatter.timeZone = TimeZone(identifier: "GMT")
        timestampFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
        timestampFormatter.locale = Locale(identifier: "en_US_POSIX")
    }
    
    func signedParametersForParameters(parameters: [String: String]) -> [String: String] {
        let sortedKeys = Array(parameters.keys).sorted(by: <)
        
        let query = sortedKeys.map { String(format: "%@=%@", $0, parameters[$0] ?? "") }.joined(separator: "&")
        
        let stringToSign = "GET\nwebservices.amazon.com\n/onca/xml\n\(query)"
        
        let dataToSign = stringToSign.data(using: String.Encoding.utf8)
        let signature = AWSSignatureSignerUtility.hmacSign(dataToSign, withKey: self.kAmazonAccessSecretKey, usingAlgorithm: UInt32(kCCHmacAlgSHA256))!
        
        var signedParams = parameters;
        signedParams["Signature"] = urlEncode(signature)
        
        return signedParams
    }
    
    public func urlEncode(_ input: String) -> String {
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        
        if let escapedString = input.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
            return escapedString
        }
        
        return ""
    }
    
    
    public func getAmazonRequestURLFor(_ asin: String) -> String{
        
        let operationParams: [String: String] = [
            "Service": "AWSECommerceService",
            "Operation": "SimilarityLookup",
            "IdType": "ASIN",
            "ItemId": asin,
            "AWSAccessKeyId": urlEncode(self.kAmazonAccessID),
            "AssociateTag": urlEncode(self.kAmazonAssociateTag),
            "Timestamp": urlEncode(timestampFormatter.string(from: Date())),]
        
        let signedParams = signedParametersForParameters(parameters: operationParams)
        
        let query = signedParams.map { "\($0)=\($1)" }.joined(separator: "&")
        let url = "https://webservices.amazon.com/onca/xml?" + query
        
        return url
    }
}
