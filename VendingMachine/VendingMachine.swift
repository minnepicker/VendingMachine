//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by morse on 3/13/19.
//  Copyright © 2019 Treehouse Island, Inc. All rights reserved.
//

import Foundation
import UIKit

/// Sets up all possibilities for FoodVendingMachine.
enum VendingSelection: String {
    case soda
    case dietSoda
    case chips
    case cookie
    case sandwich
    case wrap
    case candyBar
    case popTart
    case water
    case fruitJuice
    case sportsDrink
    case gum
    
    /// Gets the appropriate image for each item's button
    func icon() -> UIImage {
        if let image = UIImage(named: self.rawValue) {
            return image
        } else {
            return _ImageLiteralType(imageLiteralResourceName: "default")
        }
    }
}

/// Sets requirements for vending items.
protocol VendingItem {
    var price: Double { get }
    var quantity: Int { get set }
}

/// Sets requirements for the vending machine
protocol VendingMachine {
    var selection: [VendingSelection] { get }
    var inventory: [VendingSelection: VendingItem] { get set }
    var amountDeposited: Double { get set }
    
    init(inventory: [VendingSelection: VendingItem])
    func vend(selection: VendingSelection, quantity: Int) throws
    func deposit(_ amount: Double)
    func item(forSelection selection: VendingSelection) -> VendingItem?
}

/// Sets up the actual items to be vended.
struct Item: VendingItem {
    let price: Double
    var quantity: Int
}

/// Lists out posible errors for the conversion process from plist to
/// a [VendingSelection: VendingItem] dictionary.
enum InventoryError: Error {
    case invalidResource
    case conversionFalure
    case invalidSelection
}

/// Takes a file reference and returns a [String: AnyObject] dictionary.
class PlistConverter {
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String: AnyObject] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw InventoryError.invalidResource
        }
        
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
            throw InventoryError.conversionFalure
        }
        
        return dictionary
    }
}

/// Takes a [String: AnyObject] dictionary and returns a [VendingSelection: VendingItem] dictionary
class InventoryUnarchiver {
    static func vendingInventory(fromDictionary dictionary: [String: AnyObject]) throws -> [VendingSelection: VendingItem] {
        
        var inventory: [VendingSelection: VendingItem] = [:]
        
        for (key, value) in dictionary {
            if let itemDictionary = value as? [String: Any], let price = itemDictionary["price"] as? Double, let quantity = itemDictionary["quantity"] as? Int {
                let item = Item(price: price, quantity: quantity)
                
                guard let selection = VendingSelection(rawValue: key) else {
                    throw InventoryError.invalidSelection
                }
                
                inventory.updateValue(item, forKey: selection)
            }
        }
        
        return inventory
    }
}

/// Sets up possivle errors in the vend process.
enum VendingMachineError: Error {
    case invalidSelection
    case outOfStock
    case insufficientFunds(required: Double)
}

/// This is the logic for the food vending machine.
class FoodVendingMachine: VendingMachine {
    let selection: [VendingSelection] = [.soda, .dietSoda, .chips, .cookie, .sandwich, .wrap, .candyBar, .popTart, .water, .fruitJuice, .sportsDrink, .gum]
    var inventory: [VendingSelection : VendingItem]
    var amountDeposited: Double = 10.00
    
    required init(inventory: [VendingSelection : VendingItem]) {
        self.inventory = inventory
    }
    
    func vend(selection: VendingSelection, quantity: Int) throws {
        guard var item = inventory[selection] else {
            throw VendingMachineError.invalidSelection
        }
        
        guard item.quantity >= quantity else {
            throw VendingMachineError.outOfStock
        }
        
        let totalPrice = item.price * Double(quantity)
        
        if amountDeposited >= totalPrice {
            amountDeposited -= totalPrice
            
            item.quantity -= quantity
            
            inventory.updateValue(item, forKey: selection)
        } else {
            let amountRequired = totalPrice - amountDeposited
            throw VendingMachineError.insufficientFunds(required: amountRequired)
        }
    }
    
    func deposit(_ amount: Double) {
    }
    
    func item(forSelection selection: VendingSelection) -> VendingItem? {
        return inventory[selection]
    }
}
