//
//  UserSettings.swift
//  TinkoffLab
//
//  Created by Roman Tverdokhleb on 05.02.2023.
//

import Foundation

final class UserSettings {
    
    private enum SettingsKeys: String {
        case userModel
    }
    
    static var userModel: TableViewCellModel! {
        get {
            guard let savedData = UserDefaults.standard.object(forKey: SettingsKeys.userModel.rawValue) as? Data, let decodedModel = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedData) as? TableViewCellModel else { return nil }
            
            return decodedModel
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingsKeys.userModel.rawValue
            
            if let userModel = newValue {
                if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: userModel, requiringSecureCoding: false) {
                    defaults.set(savedData, forKey: key)
                }
            }
        }
        
    }
}
