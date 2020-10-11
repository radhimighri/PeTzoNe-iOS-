//
//  UserAnnotation.swift
//  PeTzoNe
//
//  Created by Radhi Mighri on 17/08/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import Foundation
import MapKit

class UserAnnotation: MKPointAnnotation {
    var uid: String?
    var age: Int?
    var profileImage: UIImage?
    var isMale: Bool?
}
