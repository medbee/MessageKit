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

import UIKit

/// A subclass of `MessageContentCell` used to display system messages.
open class SystemMessageCell: MessageCollectionViewCell {

    /// The label used to display the message's text.
    open var label = UILabel()

    /// The `MessageCellDelegate` for the cell.
    open weak var delegate: MessageCellDelegate?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }

    // MARK: - Methods

    open func setupSubviews() {
        contentView.addSubview(label)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        if #available(iOS 10.0, *) {
            label.adjustsFontForContentSizeCategory = true
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        label.attributedText = nil
        label.text = nil
    }

    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard case let .system(systemMessage) = message.kind else { fatalError("Message must be of kind .system to be displayed in SystemMessageCell") }

        label.attributedText = systemMessage
        delegate = messagesCollectionView.messageCellDelegate
    }

    /// Handle tap gesture on Label
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        delegate?.didTapMessage(in: self)
    }
}
