//
//  DataService.swift
//  901wave
//
//  Created by Umer Khan on 9/22/17.
//  Copyright © 2017 Poeen. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper

let URL_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

class DataService {
    
    static var ds = DataService()
    
    private var _Ref_Base = URL_BASE
    private var _Ref_Users = URL_BASE.child("Users")
    private var _Ref_Agendas = URL_BASE.child("Agendas")
    
    //Storage references
    private var _Ref_Post_Images = STORAGE_BASE.child("Profile-Pictures")
    
    private var _Ref_Agenda_Images = STORAGE_BASE.child("Agenda-Pictures")
    
    
    var Ref_Base:DatabaseReference {
        return _Ref_Base
    }
    
    var Ref_Users:DatabaseReference {
        return _Ref_Users
    }
    
    var Ref_Agendas:DatabaseReference {
        return _Ref_Agendas
    }
    
    var Ref_ProfilePic_Images: StorageReference{
        return _Ref_Post_Images
    }
    
    var Ref_AgendaPic_Images: StorageReference{
        return _Ref_Agenda_Images
    }
    
    var REF_USER_CURRENT: DatabaseReference{
        let uid = KeychainWrapper.defaultKeychainWrapper.string(forKey: KEY_UID)
        let user = Ref_Users.child(uid!)
        return user
    }
    
    
    func createFirebaseUser(uid:String, userData:Dictionary<String,String>) {
        Ref_Users.child(uid).updateChildValues(userData)
    }

}
