//
//  MockMessages.swift
//  SwiftyChatbot
//
//  Created by Enes Karaosman on 18.05.2020.
//  Copyright © 2020 All rights reserved.
//

import class UIKit.UIImage

public struct MockMessages {
    
    public static let sender = ChatUser(userName: "Sender")
    public static let chatbot = ChatUser(userName: "Chatbot")
    
    private static var randomUser: ChatUser {
        [sender, chatbot].randomElement()!
    }
    
    public static var mockImages: [UIImage] = []
    
    public static let messages: [ChatMessage] = [
        .init(user: Self.sender, messageKind: .text("Hi, can I ask you something!"), isSender: true),
        .init(user: Self.chatbot, messageKind: .text("Of course!")),
        .init(
            user: Self.sender,
            messageKind: .text("Okay than i am going to ask you a long question to check how row behaves, you ready?\nWhere are you now??"),
            isSender: true
        ),
        .init(user: Self.chatbot, messageKind: .location(.init(latitude: 41.04192, longitude: 28.966912))),
        .init(user: Self.chatbot, messageKind: .text("Here is photo")),
        .init(user: Self.sender, messageKind: .image(.local(UIImage(named: "landscape")!))),
        .init(user: Self.chatbot, messageKind: .text("😲"), isSender: true),
        .init(user: Self.chatbot, messageKind: .text("Here what I have.."), isSender: true),
        .init(user: Self.sender, messageKind: .image(.local(UIImage(named: "portrait")!)), isSender: true),
        .init(user: Self.chatbot, messageKind: .text("😎😎")),
        .init(user: Self.chatbot, messageKind: .text("Now it's my turn, I'll send you a link but can you open it 🤯😎\n https://github.com/EnesKaraosman/SwiftyChat")),
        .init(user: Self.chatbot, messageKind: .text("Not now but maybe later.."), isSender: true)
    ]
    
    private static func generateMessage(kind: ChatMessageKind) -> ChatMessage {
        switch kind {
        case .image:
            let randomImage = mockImages.randomElement() ?? UIImage(color: .systemGroupedBackground) ?? UIImage()
            return .init(
                user: Self.randomUser,
                messageKind: .image(.local(randomImage)),
                isSender: Self.randomUser == Self.sender
            )
        case .text:
            return .init(
                user: Self.randomUser,
                messageKind: .text(Lorem.sentence()),
                isSender: Self.randomUser == Self.sender
            )
        case .quickReply:
            let quickReplies = [
                QuickReply(title: "Option1", payload: "opt1"),
                QuickReply(title: "Option2", payload: "opt2"),
                QuickReply(title: "Option3", payload: "opt3")
            ]
            return .init(
                user: Self.randomUser,
                messageKind: .quickReply(quickReplies)
            )
        default:
            return .init(user: Self.randomUser, messageKind: .text("Bom!"))
        }
    }
    
    public static var randomMessageKind: ChatMessageKind {
        let allCases: [ChatMessageKind] = [
            .image(.local(UIImage())),
            .text(""),
            .text(""),
            .text(""),
            .text(""),
            .text(""),
            .quickReply([])
        ]
        return allCases.randomElement()!
    }
    
    public static func generatedMessages(count: Int = 30) -> [ChatMessage] {
        return (1...count).map { _ in generateMessage(kind: randomMessageKind)}
    }
    
}
