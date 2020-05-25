
class AmazonSigning{
    
    static let kAmazonAccessID = "BLAH BLAH BLAH"
    static let kAmazonAccessSecretKey = "BLAH BLAH BLAH"
    
    static let kAmazonAssociateTag = "BLAH BLAH BLAH"
    private let timestampFormatter: DateFormatter
    
    init() {
        timestampFormatter = DateFormatter()
        timestampFormatter.timeZone = TimeZone(identifier: "GMT")
        timestampFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
        timestampFormatter.locale = Locale(identifier: "en_US_POSIX")
    }
    
    private func signedParametersForParameters(parameters: [String: String]) -> [String: String] {
        let sortedKeys = Array(parameters.keys).sorted(by: <)
        
        let query = sortedKeys.map { String(format: "%@=%@", $0, parameters[$0] ?? "") }.joined(separator: "&")
        
        let stringToSign = "GET\nwebservices.amazon.com\n/onca/xml\n\(query)"
        
        let dataToSign = stringToSign.data(using: String.Encoding.utf8)
        let signature = AWSSignatureSignerUtility.hmacSign(dataToSign, withKey: AmazonAPI.kAmazonAccessSecretKey, usingAlgorithm: UInt32(kCCHmacAlgSHA256))!
        
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
    
    func send(url: String) -> String {
        guard let url = URL(string: url) else {
            print("Error! Invalid URL!") //Do something else
            return ""
        }
        
        let request = URLRequest(url: url)
        let semaphore = DispatchSemaphore(value: 0)
        
        var data: Data? = nil
        
        URLSession.shared.dataTask(with: request) { (responseData, _, _) -> Void in
            data = responseData
            semaphore.signal()
            }.resume()
        
        semaphore.wait(timeout: .distantFuture)
        
        let reply = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        return reply
    }
    
    public func getProductPrice(_ asin: AmazonStandardIdNumber) -> Double {
        
        let operationParams: [String: String] = [
            "Service": "AWSECommerceService",
            "Operation": "ItemLookup",
            "ResponseGroup": "Offers",
            "IdType": "ASIN",
            "ItemId": asin,
            "AWSAccessKeyId": urlEncode(AmazonAPI.kAmazonAccessID),
            "AssociateTag": urlEncode(AmazonAPI.kAmazonAssociateTag),
            "Timestamp": urlEncode(timestampFormatter.string(from: Date())),]
        
        let signedParams = signedParametersForParameters(parameters: operationParams)
        
        let query = signedParams.map { "\($0)=\($1)" }.joined(separator: "&")
        let url = "http://webservices.amazon.com/onca/xml?" + query
        
        let reply = send(url: url)
        
        print(reply)
    }
}
