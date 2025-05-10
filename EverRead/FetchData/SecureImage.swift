//
//  SecureImage.swift
//  EverRead
//
//  Created by Worawalan Chatlatanagulchai on 10/5/2568 BE.
//

import Foundation

// for image showing
func secureImageUrl(_ urlString: String?) -> URL? {
    guard let urlString = urlString, !urlString.isEmpty else { return nil }
    
    let secureUrlString: String
    if urlString.lowercased().hasPrefix("http://") {
        secureUrlString = "https://" + urlString.dropFirst("http://".count)
    } else if !urlString.lowercased().hasPrefix("https://") {
        secureUrlString = "https://" + urlString
    }
    else {
        secureUrlString = urlString
    }
    
    return URL(string: secureUrlString)
}
