import Foundation
import UIKit
import CoreData

typealias BookHandler = ([Book]) -> Void

final class BookManager {
    
    static let shared = BookManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "GoogleBooks")
        
        container.loadPersistentStores(completionHandler: { (storeDescrip, err) in
            if let error = err {
                fatalError(error.localizedDescription)
            }
        })
        
        return container
    }()
    
        // Set up Managed Object Context
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func getBooks(for term: String, completion: @escaping BookHandler) {
        
        guard let url = Request(searchTerm: term).getUrl() else {
            completion ([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { (dat, _, er) in
            
            var books = [Book]()
            
            if let error = er {
                print("API Request Failed: \(error.localizedDescription)")
                completion([])
                return
            }
            
            // Check data
            guard let data = dat else { return }
            
            // JSON Serialization
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let bookItems = json["items"] as! [[String: Any]]
                
                for item in bookItems {
                    let book = self.parseJSON(from: item)
                    books.append(book)
                }
                
                DispatchQueue.main.async {
                    completion(books)
                }
                
            } catch {
                print("Unable to serialized: \(error.localizedDescription)")
                completion([])
                return
            }
    
        }.resume()
    }


    func convertToBookArray(from favBooks: [FavBook]) -> [Book] {
        var books = [Book]()
    
        for favBook in favBooks {
            let book = Book(id: favBook.id!, title: favBook.title!, image: favBook.image!, authors: [favBook.authors!], publishedDate: favBook.publishedDate!, description: favBook.desc!, rating: favBook.rating, isFavorite: favBook.isFavorite)
        
            books.append(book)
        }
        return books
    }

    private func parseJSON(from item: [String: Any]) -> Book {
    
        let info: [String: Any] = item["volumeInfo"] as! [String: Any]
        let images: [String: Any] = info["imageLinks"] as! [String: Any]
    
        let id = item["id"] as? String ?? ""
        let title = info["title"] as? String ?? ""
        let image = images["thumbnail"] as? String ?? ""
        let authors = info["authors"] as? [String] ?? ["N/A"]
        let publishedDate = info["publishedDate"] as? String ?? ""
        let description = info["description"] as? String ?? ""
        let rating = info["averageRating"] as? Double ?? 0.0
        
        let book = Book(id: id, title: title, image: image, authors: authors, publishedDate: publishedDate, description: description, rating: rating, isFavorite: false)
    
        return book
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    private func check(_ book: Book) {
        let favBooks = load()
    
        for favBook in favBooks where favBook.id == book.id {
            context.delete(favBook)
            return
        }
    
    }

    func save(_ book: Book) {
        check(book)
        
        let entity = NSEntityDescription.entity(forEntityName: "FavBook", in: context)!
        let favBook = FavBook(entity: entity, insertInto: context)
        
        favBook.setValue(book.id, forKey: "id")
        favBook.setValue(book.title, forKey: "title")
        favBook.setValue(book.authors[0], forKey: "authors")
        favBook.setValue(book.image, forKey: "image")
        favBook.setValue(book.description, forKey: "desc")
        favBook.setValue(book.publishedDate, forKey: "publishedDate")
        favBook.setValue(book.rating, forKey: "rating")
        favBook.setValue(true, forKey: "isFavorite")
        
        saveContext()
        
        print("\(book.title) by \(book.authors[0]) saved in Favorites!")
    }
    
    func load() -> [FavBook] {
        let fetchRequest = NSFetchRequest<FavBook>(entityName: "FavBook")
        var favBooks = [FavBook]()
        
        do {
            favBooks = try context.fetch(fetchRequest)
        } catch {
            print("Couldn't Fetch Favorite Books: \(error.localizedDescription)")
        }

        return favBooks
    }
    
    func delete(_ favBook: FavBook) {
        context.delete(favBook)
        print("Favorite book deleted: \(favBook.title!), by \(favBook.authors!)")
        
        saveContext()
    }
    
    func deleteAll() {
        let favBooks = load()
        
        for favBook in favBooks {
            context.delete(favBook)
        }
        print("\(favBooks.count) book\(favBooks.count > 1 ? "s" : "") deleted from Favorites!")
        
        saveContext()
    }


}
