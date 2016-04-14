//
//  EVSort.swift
//
//  Created by Edwin Vermeer on 2/7/16.
//  Copyright © 2016 mirabeau. All rights reserved.
//

import Foundation

/**
 Enum that will be used to specify the order
 
 - Ascending: Sort in ascending order
 - Descending: Sort in descending order
 */
public enum SortDirection {
    case Ascending,
    Descending
}

/// Base class for the sort object
public class OrderBy {
    var field: String = ""
    var direction: SortDirection = .Descending
    var parent: OrderBy?
    
    /**
     Convenience init for creating an order object with all the parameters
     
     - parameter field:     Sort on what field
     - parameter parent:    When we sort on multiple fields then we need a chaing of OrderBy objects
     - parameter direction: Do we sort ascending or descending
     */
    public convenience init(field: String, parent: OrderBy? = nil, direction: SortDirection) {
        self.init()
        self.field = field
        self.direction = direction
        self.parent = parent
    }
    
    /**
     Chain a second sort in ascending order
     
     - parameter field: The field that we want to sort on
     
     - returns: An OrderBy object
     */
    public func Ascending(field: String) -> OrderBy {
        return OrderBy(field: field, parent: self, direction: .Ascending)
    }
    
    /**
     Chain a second sort in descending order
     
     - parameter field: The field that we want to sort on
     
     - returns: An OrderBy object
     */
    public func Descending(field: String) -> OrderBy {
        return OrderBy(field: field, parent: self, direction: .Descending)
    }
    
    /**
     Build up an array of sortDescriptors
     
     - returns: The array of sortDescriptors
     */
    public func sortDescriptors() -> [NSSortDescriptor] {
        var result: [NSSortDescriptor] = parent?.sortDescriptors() ?? []
        result.append( NSSortDescriptor(key: field, ascending: (direction == .Ascending)))
        return result
    }
}

/// The initial OrderBy class for an ascending order
public class Ascending: OrderBy {
    /**
     Initialise an ascending OrderBy object
     
     - parameter field:  The field where to sort on
     */
    public convenience required init(field: String) {
        self.init(field: field, parent: nil, direction: .Ascending)
    }
}

// The initial OrderBy class for a descending order
public class Descending: OrderBy {
    /**
     Initialise an descending OrderBy object
     
     - parameter field:  The field where to sort on
     */
    public convenience required init(field: String) {
        self.init(field: field, parent: nil, direction: .Descending)
    }
}
