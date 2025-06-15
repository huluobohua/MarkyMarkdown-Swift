//
//  MarkyMarkdownApp.swift
//  MarkyMarkdown
//
//  Created on 2025-01-15.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct MarkyMarkdownApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var preferencesManager = PreferencesManager()
    
    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            ContentView(document: file.$document)
                .environmentObject(appState)
                .environmentObject(preferencesManager)
        }
        .commands {
            // File menu additions
            CommandGroup(after: .saveItem) {
                Button("Export as PDF...") {
                    appState.exportAsPDF = true
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
                
                Button("Export as HTML...") {
                    appState.exportAsHTML = true
                }
                .keyboardShortcut("h", modifiers: [.command, .shift])
            }
            
            // Edit menu additions
            CommandGroup(after: .pasteboard) {
                Divider()
                
                Button("Bold") {
                    appState.formatBold()
                }
                .keyboardShortcut("b", modifiers: .command)
                
                Button("Italic") {
                    appState.formatItalic()
                }
                .keyboardShortcut("i", modifiers: .command)
                
                Button("Code") {
                    appState.formatCode()
                }
                .keyboardShortcut("k", modifiers: .command)
            }
            
            // View menu
            CommandMenu("View") {
                Button("Toggle Preview") {
                    appState.showPreview.toggle()
                }
                .keyboardShortcut("p", modifiers: .command)
                
                Button("Toggle WYSIWYG Mode") {
                    appState.isWYSIWYGMode.toggle()
                }
                .keyboardShortcut("e", modifiers: .command)
                
                Button("Toggle Focus Mode") {
                    appState.isFocusMode.toggle()
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Show Document Outline") {
                    appState.showOutline.toggle()
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
                
                Button("Show Writing Statistics") {
                    appState.showStatistics.toggle()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
            
            // Format menu
            CommandMenu("Format") {
                Button("Heading 1") {
                    appState.formatHeading(1)
                }
                .keyboardShortcut("1", modifiers: .command)
                
                Button("Heading 2") {
                    appState.formatHeading(2)
                }
                .keyboardShortcut("2", modifiers: .command)
                
                Button("Heading 3") {
                    appState.formatHeading(3)
                }
                .keyboardShortcut("3", modifiers: .command)
                
                Divider()
                
                Button("Quote") {
                    appState.formatQuote()
                }
                .keyboardShortcut("'", modifiers: .command)
                
                Button("List") {
                    appState.formatList()
                }
                .keyboardShortcut("l", modifiers: .command)
                
                Button("Link...") {
                    appState.showLinkDialog = true
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
            }
            
            // AI menu
            CommandMenu("AI Assistant") {
                Button("Rewrite Selection") {
                    appState.aiAction = .rewrite
                }
                .keyboardShortcut("r", modifiers: [.command, .option])
                
                Button("Continue Writing") {
                    appState.aiAction = .continue
                }
                .keyboardShortcut("c", modifiers: [.command, .option])
                
                Button("Summarize") {
                    appState.aiAction = .summarize
                }
                .keyboardShortcut("s", modifiers: [.command, .option])
                
                Button("Fix Grammar") {
                    appState.aiAction = .fixGrammar
                }
                .keyboardShortcut("g", modifiers: [.command, .option])
                
                Divider()
                
                Button("AI Settings...") {
                    appState.showAISettings = true
                }
            }
        }
        
        Settings {
            PreferencesView()
                .environmentObject(preferencesManager)
        }
    }
}

// App State
class AppState: ObservableObject {
    @Published var showPreview = true
    @Published var isWYSIWYGMode = false
    @Published var isFocusMode = false
    @Published var showOutline = false
    @Published var showStatistics = false
    @Published var showLinkDialog = false
    @Published var showAISettings = false
    @Published var exportAsPDF = false
    @Published var exportAsHTML = false
    @Published var aiAction: AIAction?
    
    // Formatting actions
    var formatBold: () -> Void = {}
    var formatItalic: () -> Void = {}
    var formatCode: () -> Void = {}
    var formatHeading: (Int) -> Void = { _ in }
    var formatQuote: () -> Void = {}
    var formatList: () -> Void = {}
}

enum AIAction {
    case rewrite
    case `continue`
    case summarize
    case fixGrammar
}

// Document model
struct MarkdownDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [.plainText, .init(filenameExtension: "md")!, .init(filenameExtension: "markdown")!]
    }
    
    var text: String
    
    init(text: String = "# Welcome to MarkyMarkdown\n\nStart writing...") {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let string = String(data: data, encoding: .utf8) {
            text = string
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}