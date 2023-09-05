//
//  Person.swift
//  Project10
//
//  Created by Guga Dolidze on 9/5/23.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
