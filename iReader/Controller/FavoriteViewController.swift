import UIKit

class FavoriteViewController: SearchViewController {
    
    override func viewDidLoad() {
        loadBooks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadBooks()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? DetailViewController {
            detailVC.book = currentBook!
        }
    }
    
    private func loadBooks() {
        let favBooks = BookManager.shared.load()
        let bks = BookManager.shared.convertToBookArray(from: favBooks)
        books = bks.reversed()
    }
    
}


extension FavoriteViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentBook = books[indexPath.row]
        performSegue(withIdentifier: "segueFromFavorites", sender: (Any).self)
    }
    
}
