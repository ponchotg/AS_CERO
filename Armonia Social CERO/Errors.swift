//
//  Errors.swift
//  Armonia Social CERO
//
//  Created by Alfonso Tapia on 7/20/17.
//  Copyright © 2017 Paranoid Interactive. All rights reserved.
//

import Foundation

enum UserError:Error {
    case lineNotFound(String)
    case notEnoughComments(SearchType)
    case hasNoScore(SearchType)
}

enum UserPassError:Error{
    case notEmailForm()
    case emptyField(field:String)
    case shortPassword()
}

enum ImageConversion:Error{
    case ResizeFailure
    case DataConversionFailed
}
