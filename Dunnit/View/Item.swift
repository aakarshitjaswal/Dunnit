//
//  Item.swift
//  Dunnit
//
//  Created by Aakarshit Jaswal on 28/01/22.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted(originProperty: "items") var parentCategory: LinkingObjects<Category>
}
