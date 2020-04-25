//
//  FlickrJSON.swift
//  VirtualTourist
//
//  Created by Gregory White on 4/20/20.
//  Copyright © 2020 Gregory White. All rights reserved.
//

import Foundation

struct Photo: Decodable {
    var id:       String
    var owner:    String
    var secret:   String
    var server:   String
    var farm:     Int
    var title:    String
    var ispublic: Int
    var isfriend: Int
    var isfamily: Int
    var url:      String
    var height:   Int
    var width:    Int
    
    enum CodingKeys: String, CodingKey {
        case url    = "url_m"
        case height = "height_m"
        case width  = "width_m"
        
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case ispublic
        case isfriend
        case isfamily
    }

}

struct Photos: Decodable {
    var page:    Int
    var pages:   Int
    var perpage: Int
    var total:   String
    var photo:   [Photo]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perpage
        case total
        case photo
    }
    
}

extension Photos {
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        page    = try values.decode(Int.self, forKey: .page)
        pages   = try values.decode(Int.self, forKey: .pages)
        perpage = try values.decode(Int.self, forKey: .perpage)
        total   = try values.decode(String.self, forKey: .total)
        photo   = try values.decode([Photo].self, forKey: .photo)
    }
    
}

struct GetListOfPhotosResponse: Decodable {
    var photos: Photos
    var stat: String
}

extension GetListOfPhotosResponse {
    var isOK:     Bool  { return stat == "ok" }
    var page:     Int64 { return Int64(photos.page) }
    var pages:    Int64 { return Int64(photos.pages) }
    var perpage:  Int64 { return Int64(photos.perpage) }
    var total:    Int64 { return Int64(photos.total)! }
}

