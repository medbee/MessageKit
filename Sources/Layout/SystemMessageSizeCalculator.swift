/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

open class SystemMessageSizeCalculator: MessageSizeCalculator {

    public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        self.layout = layout
    }

    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let layout = layout else { return .zero }

        let collectionViewWidth = layout.collectionView?.bounds.width ?? 0
        let contentInset = layout.collectionView?.contentInset ?? .zero
        let inset = layout.sectionInset.left + layout.sectionInset.right + contentInset.left + contentInset.right

        guard let messagesCollectionViewFlowLayout = layout as? MessagesCollectionViewFlowLayout else { return .zero }
        guard let messagesCollectionView = layout.collectionView as? MessagesCollectionView else { return .zero }

        let message = messagesCollectionViewFlowLayout.messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        guard case .system = message.kind else { return .zero }

        return CGSize(width: collectionViewWidth - inset, height: 44)
    }

    open override func messageContainerSize(for message: MessageType) -> CGSize {
        guard let layout = layout else { return .zero }

        let collectionViewWidth = layout.collectionView?.bounds.width ?? 0
        let contentInset = layout.collectionView?.contentInset ?? .zero
        let inset = layout.sectionInset.left + layout.sectionInset.right + contentInset.left + contentInset.right

        guard case .custom = message.kind else { return .zero }
        return CGSize(width: collectionViewWidth - inset, height: 44)
    }
}
