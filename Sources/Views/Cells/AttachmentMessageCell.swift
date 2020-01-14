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

/// A subclass of `MessageContentCell` used to display attachment messages.
open class AttachmentMessageCell: MessageContentCell {

    private var aspectRatioConstraint: NSLayoutConstraint?

    // MARK: - Properties

    /// The `MessageCellDelegate` for the cell.
    open override weak var delegate: MessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }

    /// The label used to display the message's text.
    open var messageLabel: MessageLabel = {
        let label = MessageLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// The image view display the media content.
    open var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return imageView
    }()

    // MARK: - Methods

    /// Responsible for setting up the constraints of the cell's subviews.
    open func setupConstraints() {
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.messageContainerView.topAnchor),
            self.imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: 250),

            self.messageLabel.leadingAnchor.constraint(equalTo: self.messageContainerView.leadingAnchor),
            self.messageLabel.trailingAnchor.constraint(equalTo: self.messageContainerView.trailingAnchor),
            self.messageLabel.bottomAnchor.constraint(equalTo: self.messageContainerView.bottomAnchor),
            self.messageLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor)
        ])
    }

    open override func setupSubviews() {
        super.setupSubviews()
        self.messageContainerView.addSubview(self.imageView)
        self.messageContainerView.addSubview(self.messageLabel)
        self.setupConstraints()
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.messageLabel.attributedText = nil
        self.messageLabel.text = nil

        guard let aspectRatioConstraint = self.aspectRatioConstraint else { return }

        self.imageView.removeConstraint(aspectRatioConstraint)
        self.aspectRatioConstraint = nil
    }

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }

        messageLabel.textInsets = attributes.messageLabelInsets
        messageLabel.messageLabelFont = attributes.messageLabelFont
    }

    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }

        guard case .attachment(let text, let item) = message.kind else { return }

        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesCollectionView)
        self.messageLabel.configure {
            self.messageLabel.enabledDetectors = enabledDetectors
            for detector in enabledDetectors {
                let attributes = displayDelegate.detectorAttributes(for: detector, and: message, at: indexPath)
                self.messageLabel.setAttributes(attributes, detector: detector)
            }

            let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
            self.messageLabel.text = text
            self.messageLabel.textColor = textColor
            if let font = messageLabel.messageLabelFont {
                self.messageLabel.font = font
            }
        }

        let image = item.image ?? item.placeholderImage
        self.imageView.image = image
        let multiplier = image.size.aspectRatio
        let aspectRatioConstraint = self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: multiplier, constant: 0)
        aspectRatioConstraint.isActive = true
        self.aspectRatioConstraint = aspectRatioConstraint
    }

    /// Used to handle the cell's contentView's tap gesture.
    /// Return false when the contentView does not need to handle the gesture.
    open override func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        let convertedPoint = self.messageContainerView.convert(touchPoint, to: self.messageLabel)
        return self.messageLabel.handleGesture(convertedPoint)
    }
}

private extension AttachmentMessageCell {

    func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral

        return CGSize(width: rect.width, height: rect.height + messageLabel.textInsets.horizontal)
    }
}
