//
//  ChatView.swift
//  SwiftyChatbot
//
//  Created by Enes Karaosman on 19.05.2020.
//  Copyright © 2020 All rights reserved.
//

import SwiftUI
import Combine

extension UITableView {
    func scrollToBottom(animated: Bool, yOffset: Binding<CGFloat>) {
        let y = contentSize.height - frame.size.height
        if y < 0 { return }
        yOffset.wrappedValue = y
    }
}

public struct ChatView: View {
    
    @Binding public var messages: [ChatMessage]
    public var inputView: (_ proxy: GeometryProxy) -> AnyView

    private var onMessageCellTapped: (ChatMessage) -> Void = { msg in print(msg.messageKind) }
    private var messageCellContextMenu: (ChatMessage) -> AnyView = { _ in EmptyView().embedInAnyView() }
    private var onQuickReplyItemSelected: (QuickReplyItem) -> Void = { _ in }
    private var contactCellFooterSection: (ContactItem, ChatMessage) -> [ContactCellButton] = { _, _ in [] }
    private var onAttributedTextTappedCallback: () -> AttributedTextTappedCallback = { return AttributedTextTappedCallback() }
    private var onCarouselItemAction: (CarouselItemButton, ChatMessage) -> Void = { (_, _) in }
    
    @State private var tableView: UITableView?
    @State private var yOffset: CGFloat = 0
    
    private func scrollToBottom() {
        withAnimation {
            self.tableView?.scrollToBottom(animated: true, yOffset: self.$yOffset)
        }
    }
    
    public init(
        messages: Binding<[ChatMessage]>,
        inputView: @escaping (_ proxy: GeometryProxy) -> AnyView
    ) {
        self._messages = messages
        self.inputView = inputView
    }
    
    public var body: some View {
        DeviceOrientationBasedView(
            portrait: { GeometryReader { self.body(in: $0) } },
            landscape: { GeometryReader { self.body(in: $0) } }
        )
        .environmentObject(OrientationInfo())
        .edgesIgnoringSafeArea(.bottom)
        .onReceive(Just(messages)) { (value) in
            print(value.count)
            self.scrollToBottom()
        }
//        .onAppear {
//            // To remove only extra separators below the list:
//            UITableView.appearance().tableFooterView = UIView()
//            // To remove all separators including the actual ones:
//            UITableView.appearance().separatorStyle = .none
//        }
    }
    
    // MARK: - Body in geometry
    private func body(in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            
            Group {
                if #available(iOS 14.0, *) {
                    self.iOS14Body(in: geometry)
                } else {
                    self.iOS14Fallback(in: geometry)
                }
            }
            
            .padding(.bottom, geometry.safeAreaInsets.bottom + 56)

            self.inputView(geometry)

        }
        .keyboardAwarePadding()
        .dismissKeyboardOnTappingOutside()
    }
    
    @available(iOS 14.0, *)
    private func iOS14Body(in geometry: GeometryProxy) -> some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack {
                    ForEach(self.messages) { message in
                        self.chatMessageCellContainer(in: geometry.size, with: message)
                    }
                }
            }
        }
    }
    
    private func iOS14Fallback(in geometry: GeometryProxy) -> some View {
        List(self.messages) { message in
            self.chatMessageCellContainer(in: geometry.size, with: message)
        }
        .introspectTableView(customize: { tableView in
            if self.tableView == nil { self.tableView = tableView }
            else {
                self.tableView?.setContentOffset(CGPoint(x: 0, y: self.yOffset), animated: true)
            }
            self.tableView?.tableFooterView = UIView()
            self.tableView?.separatorStyle = .none
        })
    }
    
    // MARK: - List Item
    private func chatMessageCellContainer(in size: CGSize, with message: ChatMessage) -> some View {
        ChatMessageCellContainer(
            message: message,
            size: size,
            onQuickReplyItemSelected: self.onQuickReplyItemSelected,
            contactFooterSection: self.contactCellFooterSection,
            onTextTappedCallback: self.onAttributedTextTappedCallback,
            onCarouselItemAction: self.onCarouselItemAction
        )
        .onTapGesture {
            self.onMessageCellTapped(message)
        }
        .contextMenu(menuItems: {
            self.messageCellContextMenu(message)
        })
        .modifier(AvatarModifier(message: message))
        .modifier(MessageModifier(messageKind: message.messageKind, isSender: message.isSender))
        .modifier(CellEdgeInsetsModifier(isSender: message.isSender))
        .id(message.id)
    }
    
}

public extension ChatView {
    
    /// Triggered when a ChatMessage is tapped.
    func onMessageCellTapped(_ action: @escaping (ChatMessage) -> Void) -> ChatView {
        var copy = self
        copy.onMessageCellTapped = action
        return copy
    }
    
    /// Present ContextMenu when a message cell is long pressed.
    func messageCellContextMenu(_ action: @escaping (ChatMessage) -> AnyView) -> ChatView {
        var copy = self
        copy.messageCellContextMenu = action
        return copy
    }
    
    /// Triggered when a quickReplyItem is selected (ChatMessageKind.quickReply)
    func onQuickReplyItemSelected(_ action: @escaping (QuickReplyItem) -> Void) -> ChatView {
        var copy = self
        copy.onQuickReplyItemSelected = action
        return copy
    }
    
    /// Present contactItem's footer buttons. (ChatMessageKind.contactItem)
    func contactItemButtons(_ section: @escaping (ContactItem, ChatMessage) -> [ContactCellButton]) -> ChatView {
        var copy = self
        copy.contactCellFooterSection = section
        return copy
    }
    
    /// To listen text tapped events like phone, url, date, address
    func onAttributedTextTappedCallback(action: @escaping () -> AttributedTextTappedCallback) -> ChatView {
        var copy = self
        copy.onAttributedTextTappedCallback = action
        return copy
    }
    
    /// Triggered when the carousel button tapped.
    func onCarouselItemAction(action: @escaping (CarouselItemButton, ChatMessage) -> Void) -> ChatView {
        var copy = self
        copy.onCarouselItemAction = action
        return copy
    }
    
}
