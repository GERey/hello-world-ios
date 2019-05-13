//
//  CacheableUserEnvironments.swift
//  LaunchDarkly
//
//  Created by Mark Pokorny on 3/19/19. +JMJ
//  Copyright © 2019 Catamorphic Co. All rights reserved.
//

import Foundation

//Data structure used to cache feature flags for a specific user for multiple environments
//Cache model in use from 4.0.0
/*
[<userKey>: [
    “userKey”: <userKey>,                               //CacheableUserEnvironment dictionary
    “environmentFlags”: [
        <mobileKey>: [
            “userKey”: <userKey>,                       //CacheableEnvironmentFlags dictionary
            “mobileKey”: <mobileKey>,
            “featureFlags”: [
                <flagKey>: [
                    “key”: <flagKey>,                   //FeatureFlag dictionary
                    “version”: <modelVersion>,
                    “flagVersion”: <flagVersion>,
                    “variation”: <variation>,
                    “value”: <value>,
                    “trackEvents”: <trackEvents>,       //EventTrackingContext
                    “debugEventsUntilDate”: <debugEventsUntilDate>
                    ]
                ]
            ]
        ],
    “lastUpdated”: <lastUpdated>
    ]
]
*/
struct CacheableUserEnvironmentFlags {
    enum CodingKeys: String, CodingKey {
        case userKey, environmentFlags, lastUpdated
    }

    let userKey: String
    let environmentFlags: [MobileKey: CacheableEnvironmentFlags]
    let lastUpdated: Date

    init(userKey: String, environmentFlags: [MobileKey: CacheableEnvironmentFlags], lastUpdated: Date) {
        (self.userKey, self.environmentFlags, self.lastUpdated) = (userKey, environmentFlags, lastUpdated)
    }

    init?(dictionary: [String: Any]) {
        guard let userKey = dictionary[CodingKeys.userKey.rawValue] as? String,
            let environmentFlagsDictionary = dictionary[CodingKeys.environmentFlags.rawValue] as? [MobileKey: [LDFlagKey: Any]],
            let lastUpdated = (dictionary[CodingKeys.lastUpdated.rawValue] as? String)?.dateValue
        else {
            return nil
        }
        let environmentFlags = environmentFlagsDictionary.compactMapValues { (cacheableEnvironmentFlagsDictionary) in
            return CacheableEnvironmentFlags(dictionary: cacheableEnvironmentFlagsDictionary)
        }
        self.init(userKey: userKey, environmentFlags: environmentFlags, lastUpdated: lastUpdated)
    }

    init?(object: Any) {
        guard let dictionary = object as? [String: Any]
        else {
            return nil
        }
        self.init(dictionary: dictionary)
    }

    static func makeCollection(from dictionary: [String: Any]) -> [UserKey: CacheableUserEnvironmentFlags]? {
        guard !dictionary.isEmpty
        else {
            return [:]
        }
        let cacheableUserEnvironmentsCollection = dictionary.compactMapValues { (element) in
            return CacheableUserEnvironmentFlags(object: element)
        }
        guard !cacheableUserEnvironmentsCollection.isEmpty
        else {
            return nil
        }
        return cacheableUserEnvironmentsCollection
    }

    var dictionaryValue: [String: Any] {
        return [CodingKeys.userKey.rawValue: userKey,
                CodingKeys.lastUpdated.rawValue: lastUpdated.stringValue,
                CodingKeys.environmentFlags.rawValue: environmentFlags.compactMapValues({ (cacheableEnvironmentFlags) -> [String: Any] in
                    return cacheableEnvironmentFlags.dictionaryValue
                })]
    }
}

extension Dictionary where Key == UserKey, Value == CacheableUserEnvironmentFlags {
    var dictionaryValues: [UserKey: [String: Any]] {
        return compactMapValues { (cacheableUserEnvironment) in
            return cacheableUserEnvironment.dictionaryValue
        }
    }
}

extension DateFormatter {
    ///Date formatter configured to format dates to/from the format 2018-08-13T19:06:38.123Z
    class var ldDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }
}

extension Date {
    ///Date string using the format 2018-08-13T19:06:38.123Z
    var stringValue: String {
        return DateFormatter.ldDateFormatter.string(from: self)
    }

    //When a date is converted to JSON, the resulting string is not as precise as the original date (only to the nearest .001s)
    //By converting the date to json, then back into a date, the result can be compared with any date re-inflated from json
    ///Date truncated to the nearest millisecond, which is the precision for string formatted dates
    var stringEquivalentDate: Date {
        return stringValue.dateValue
    }
}

extension String {
    ///Date converted from a string using the format 2018-08-13T19:06:38.123Z
    var dateValue: Date {
        return DateFormatter.ldDateFormatter.date(from: self) ?? Date()
    }
}
