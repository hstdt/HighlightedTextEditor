#if os(iOS)
import SwiftUI
import UIKit

public struct HighlightedTextEditor: UIViewRepresentable, HighlightingTextEditor {

    @Binding var text: String {
        didSet {
            self.onTextChange(text)
        }
    }
    let highlightRules: [HighlightRule]
    
    var onEditingChanged                   : () -> Void                   = {}
    var onCommit                           : () -> Void                   = {}
    var onTextChange                       : (String) -> Void             = { _ in }
    
    // autocapitalizationType, autocorrectionType and keyboardType will be private(set) in a future 2.0.0 breaking release
                 var autocapitalizationType: UITextAutocapitalizationType = .sentences
                 var autocorrectionType    : UITextAutocorrectionType     = .default
    private(set) var backgroundColor       : UIColor?                     = nil
    private(set) var color                 : UIColor?                     = nil
    private(set) var font                  : UIFont?                      = nil
    private(set) var insertionPointColor   : UIColor?                     = nil
                 var keyboardType          : UIKeyboardType               = .default
    private(set) var textAlignment         : TextAlignment                = .leading
    
    public init(
        text: Binding<String>,
        highlightRules: [HighlightRule],
        onEditingChanged: @escaping () -> Void = {},
        onCommit: @escaping () -> Void = {},
        onTextChange: @escaping (String) -> Void = { _ in }
    ) {
        _text = text
        self.highlightRules = highlightRules
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.onTextChange = onTextChange
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isScrollEnabled = true
        updateTextViewModifiers(textView)

        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.isScrollEnabled = false
        
        let highlightedText = HighlightedTextEditor.getHighlightedText(
            text: text,
            highlightRules: highlightRules,
            font: font,
            color: color
        )

        if let range = uiView.markedTextNSRange {
            uiView.setAttributedMarkedText(highlightedText, selectedRange: range)
        } else {
            uiView.attributedText = highlightedText
        }
        updateTextViewModifiers(uiView)
        uiView.isScrollEnabled = true
        uiView.selectedTextRange = context.coordinator.selectedTextRange
    }
    
    private func updateTextViewModifiers(_ textView: UITextView) {
        // Keyboard properties are changed only if user closes the on-screen keyboard and reopens it (system behavior)
        textView.keyboardType = keyboardType
        textView.autocapitalizationType = autocapitalizationType
        textView.autocorrectionType = autocorrectionType
        
        textView.backgroundColor = backgroundColor
        let layoutDirection = UIView.userInterfaceLayoutDirection(for: textView.semanticContentAttribute)
        textView.textAlignment = NSTextAlignment(textAlignment: textAlignment, userInterfaceLayoutDirection: layoutDirection)
        textView.tintColor = insertionPointColor ?? textView.tintColor
    }

    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: HighlightedTextEditor
        var selectedTextRange: UITextRange? = nil

        init(_ markdownEditorView: HighlightedTextEditor) {
            self.parent = markdownEditorView
        }
        
        public func textViewDidChange(_ textView: UITextView) {

            // For Multistage Text Input
            guard textView.markedTextRange == nil else { return }
            
            self.parent.text = textView.text
            selectedTextRange = textView.selectedTextRange
        }
        
        public func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onEditingChanged()
        }
        
        public func textViewDidEndEditing(_ textView: UITextView) {
            parent.onCommit()
        }
    }
}

extension HighlightedTextEditor {
    
    public func autocapitalizationType(_ type: UITextAutocapitalizationType) -> Self {
        var new = self
        new.autocapitalizationType = type
        return new
    }
    
    public func autocorrectionType(_ type: UITextAutocorrectionType) -> Self {
        var new = self
        new.autocorrectionType = type
        return new
    }
    
    public func backgroundColor(_ color: UIColor) -> Self {
        var new = self
        new.backgroundColor = color
        return new
    }
    
    // Overwritten by font attributes in your HighlightRules
    public func defaultColor(_ color: UIColor) -> Self {
        var new = self
        new.color = color
        return new
    }
    
    // Overwritten by font attributes in your HighlightRules
    public func defaultFont(_ font: UIFont) -> Self {
        var new = self
        new.font = font
        return new
    }
    
    public func keyboardType(_ type: UIKeyboardType) -> Self {
        var new = self
        new.keyboardType = type
        return new
    }
    
    public func insertionPointColor(_ color: UIColor) -> Self {
        var new = self
        new.insertionPointColor = color
        return new
    }
    
    public func multilineTextAlignment(_ alignment: TextAlignment) -> Self {
        var new = self
        new.textAlignment = alignment
        return new
    }
}
#endif
