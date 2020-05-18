import Foundation
import UIKit

typealias ImageHandler = (UIImage?) -> Void

struct Book {
    
    let id: String
    let title: String
    let image: String
    let authors: [String]
    let publishedDate: String
    let description: String
    let rating: Double
    var isFavorite: Bool
    
    func getImage(completion: @escaping ImageHandler) {
        
        guard let url = URL(string: image) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url ) { (dat, _, _) in
            if let data = dat {
                DispatchQueue.main.async {
                    completion(UIImage(data: data))
                }
            }
        }.resume()
    }
    
}
