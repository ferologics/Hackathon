
import UIKit

class SearchViewCell: UITableViewCell {

	@IBOutlet weak var nameField:     UITextField
	@IBOutlet weak var costField:     UITextField
	@IBOutlet weak var capacityField: UITextField
	@IBOutlet weak var dateField:     UITextField

	public func configure(#name: Strig?, ticketClasses:(names:[String], costs:[Int]), capacity:Int?, date:NSDate?) {

	nameField.text     = name
	costField.text     = regularTicketClass(ticketClasses)
	capacityField.text = String(Int)
	dateField.text     = utcToString(date)

	nameField.accessibilityValue     = name
	costField.accessibilityValue     = regularTicketClass(ticketClasses)
	capacityField.accessibilityValue = capacity
	dateField.accessibilityValue     = utcToString(date)

	}

	func utcToString(date: NSDate) -> String {
		var dateFormatter = NSDateFormatter() // Format Date
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz" //format style. Browse online to get a format that fits your needs.
								 //"yyyy-MM-dd'T'HH:mm:ss'Z'" maybe?
		var dateString = dateFormatter.stringFromDate(date)

		return dateString
	}

	// get ticketclass names array and cost array for hackathon, then find the on ewith "regular" name and returm its name + cost as a tuple
	func regularTicketClass(ticketClasses:(names: [String], costs: [Int])) ->  String {

		let regularTicketClassCost = String(ticketClasses.cost.sort(<)[0])
		let regularTicketClassName = filter(ticketClasses.names) { $0.name == "regular" }
		let unifiedString = regularTicketClassName + ": " + regularTicketClassCost
		return unifiedString

	}



}
