//
//  Person.swift
//  IRAlderAssignment
//
//  Created by Ihor Rudych on 5/30/18.
//  Copyright © 2018 Ihor Rudych. All rights reserved.
//

import Foundation
public class Person: NSObject {
    public var id: String
    public var firstName: String
    public var lastName: String
    public var birthDate: String
    public var profilePicture: String
    public var forceSensitive: String
    public var affiliation: String
    
    public init(id: String, firstName: String, lastName: String, birthDate: String, profilePicture: String, forceSensitive: String, affiliation: String) {
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.profilePicture = profilePicture
        self.forceSensitive = forceSensitive
        self.affiliation = affiliation
    }
}
