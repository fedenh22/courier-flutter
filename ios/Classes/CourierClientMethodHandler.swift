//
//  CourierClientMethodHandler.swift
//  courier_flutter
//
//  Created by Michael Miller on 8/2/24.
//

import Foundation
import Courier_iOS

internal class CourierClientMethodHandler: NSObject, FlutterPlugin {
    
    static func getChannel(with registrar: FlutterPluginRegistrar) -> FlutterMethodChannel {
        return FlutterMethodChannel(name: CourierFlutterChannel.client.rawValue, binaryMessenger: registrar.messenger())
    }
    
    static func register(with registrar: any FlutterPluginRegistrar) {
        registrar.addMethodCallDelegate(
            CourierClientMethodHandler(),
            channel: CourierClientMethodHandler.getChannel(with: registrar)
        )
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        Task {
            
            do {
                
                guard let params = call.arguments as? Dictionary<String, Any>, let client = try params.toClient() else {
                    throw CourierFlutterError.missingParameter(value: "client")
                }
                
                switch call.method {
                    
                    // MARK: Brand
                    
                case "brands.get_brand":
                    
                    let (brandId): (String) = (
                        try params.extract("brandId")
                    )
                    
                    let brand = try await client.brands.getBrand(
                        brandId: brandId
                    )
                    
                    let json = try brand.toJson()
                    result(json)
                    
                    // MARK: Token Management
                    
                case "tokens.put_user_token":
                    
                    let (token, provider): (String, String) = (
                        try params.extract("token"),
                        try params.extract("provider")
                    )
                    
                    let deviceParams = params["device"] as? [String: Any]
                    let device = try deviceParams?.toCourierDevice()
                    
                    try await client.tokens.putUserToken(
                        token: token,
                        provider: provider,
                        device: device ?? CourierDevice()
                    )
                    
                    result(nil)
                    
                case "tokens.delete_user_token":
                    
                    let (token): (String) = (
                        try params.extract("token")
                    )
                    
                    try await client.tokens.deleteUserToken(
                        token: token
                    )
                    
                    result(nil)
                    
                    // MARK: Preferences
                    
                case "preferences.get_user_preferences":
                    
                    let paginationCursor = params["paginationCursor"] as? String
                    
                    let res = try await client.preferences.getUserPreferences(
                        paginationCursor: paginationCursor
                    )
                    
                    let json = try res.toJson()
                    result(json)
                    
                case "preferences.get_user_preference_topic":
                    
                    let topicId: String = try params.extract("topicId")
                    
                    let res = try await client.preferences.getUserPreferenceTopic(
                        topicId: topicId
                    )
                    
                    let json = try res.toJson()
                    result(json)
                    
                case "preferences.put_user_preference_topic":
                    
                    let (topicId, status, hasCustomRouting, customRouting): (String, String, Bool, [String]) = (
                        try params.extract("topicId"),
                        try params.extract("status"),
                        try params.extract("hasCustomRouting"),
                        try params.extract("customRouting")
                    )
                    
                    try await client.preferences.putUserPreferenceTopic(
                        topicId: topicId,
                        status: CourierUserPreferencesStatus(rawValue: status) ?? .unknown,
                        hasCustomRouting: hasCustomRouting,
                        customRouting: customRouting.map { CourierUserPreferencesChannel(rawValue: $0) ?? .unknown }
                    )
                    
                    result(nil)
                    
                    // MARK: Inbox
                    
                case "inbox.get_messages":
                    
                    let paginationLimit = params["paginationLimit"] as? Int
                    let startCursor = params["startCursor"] as? String

                    let res = try await client.inbox.getMessages(
                        paginationLimit: paginationLimit ?? Courier.shared.inboxPaginationLimit,
                        startCursor: startCursor
                    )

                    let json = res.toDictionary().toJson()
                    result(json)

                case "inbox.get_archived_messages":
                    
                    let paginationLimit = params["paginationLimit"] as? Int
                    let startCursor = params["startCursor"] as? String

                    let res = try await client.inbox.getArchivedMessages(
                        paginationLimit: paginationLimit ?? Courier.shared.inboxPaginationLimit,
                        startCursor: startCursor
                    )

                    let json = res.toDictionary().toJson()
                    result(json)

                case "inbox.get_unread_message_count":
                    
                    let count = try await client.inbox.getUnreadMessageCount()
                    result(count)

                case "inbox.get_message_by_id":
                    
                    let messageId: String = try params.extract("messageId")

                    let res = try await client.inbox.getMessage(
                        messageId: messageId
                    )

                    let json = res.toDictionary().toJson()
                    result(json)

                case "inbox.click_message":
                    
                    let (messageId, trackingId): (String, String) = (
                        try params.extract("messageId"),
                        try params.extract("trackingId")
                    )

                    try await client.inbox.click(
                        messageId: messageId,
                        trackingId: trackingId
                    )

                    result(nil)

                case "inbox.unread_message":
                    
                    let messageId: String = try params.extract("messageId")

                    try await client.inbox.unread(
                        messageId: messageId
                    )

                    result(nil)

                case "inbox.read_message":
                    
                    let messageId: String = try params.extract("messageId")

                    try await client.inbox.read(
                        messageId: messageId
                    )

                    result(nil)

                case "inbox.open_message":
                    
                    let messageId: String = try params.extract("messageId")

                    try await client.inbox.open(
                        messageId: messageId
                    )

                    result(nil)

                case "inbox.archive_message":
                    
                    let messageId: String = try params.extract("messageId")

                    try await client.inbox.archive(
                        messageId: messageId
                    )

                    result(nil)

                case "inbox.read_all_messages":
                    
                    try await client.inbox.readAll()
                    result(nil)
                    
                    // MARK: Tracking
                    
                case "tracking.post_tracking_url":
                    
                    let (url, event): (String, String) = (
                        try params.extract("url"),
                        try params.extract("event")
                    )
                    
                    guard let trackingEvent = CourierTrackingEvent(rawValue: event) else {
                        throw CourierFlutterError.missingParameter(value: "tracking_event")
                    }
                    
                    try await client.tracking.postTrackingUrl(
                        url: url,
                        event: trackingEvent
                    )
                    
                    result(nil)
                    
                default:
                    
                    result(FlutterMethodNotImplemented)
                    
                }
                
            } catch {
                
                result(error.toFlutterError())
                
            }
            
        }
          
    }
    
}