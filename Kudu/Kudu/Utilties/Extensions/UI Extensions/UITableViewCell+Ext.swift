import UIKit

extension UITableViewCell {
    
    /// Variable to get default reuseIdentifier
    public static var defaultReuseIdentifier: String {
        return "\(self)"
    }

    static func getEmptyCell() -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
}
