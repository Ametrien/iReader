import UIKit

class SearchViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    

    let searchController = UISearchController(searchResultsController: nil)
    
    var height: CGFloat = 260
    var column: CGFloat = 2
    var spacing: CGFloat = 10
    var currentBook: Book?
    
    var books = [Book]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var favBooks: [FavBook]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Search bar
        searchController.searchBar.placeholder = "Type book or author here..."
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        favBooks = BookManager.shared.load()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? DetailViewController {
            
            for favBook in favBooks! where favBook.id == currentBook!.id {
                currentBook!.isFavorite = true
                print("Book is already saved!")
            }
            
            detailVC.book = currentBook!
        }
    }

}

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    // Search bar
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Check searchbar text
        guard let searchText = searchController.searchBar.text else { return }
        // Fetch the searched book
        BookManager.shared.getBooks(for: searchText) { [unowned self] booksArr in
            self.books = booksArr
        }
        
        navigationItem.searchController?.isActive = false
        
    }
}

    // View Data Source
extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookView.identifier, for: indexPath) as! BookView
        
        // Assign Book to a cell
        let book = books[indexPath.row]
        cell.book = book
        
        return cell
    }

    
}


    // View Delegate Flow Layout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - (spacing * 4)) / column
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        currentBook = books[indexPath.row]
        performSegue(withIdentifier: "segueFromSearch", sender: (Any).self)
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
}
