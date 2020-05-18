import Foundation

struct Request {
    
    let base = "https://www.googleapis.com/books/v1/volumes?q="
    let searchTerm: String
    
    func getUrl() -> URL? {
        return URL(string: base + convertToUrl(from: searchTerm))!
    }
    
    private func convertToUrl(from search: String) -> String {
        let newString = search.replacingOccurrences(of: " ", with: "+")
        return newString
    }
    
}
