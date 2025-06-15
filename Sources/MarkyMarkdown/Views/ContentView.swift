//
//  ContentView.swift
//  MarkyMarkdown
//
//  Created on 2025-01-15.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: MarkdownDocument
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var preferences: PreferencesManager
    @State private var splitRatio: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            if appState.isWYSIWYGMode {
                WYSIWYGView(document: $document)
            } else {
                HSplitView {
                    // Editor
                    MarkdownEditor(text: $document.text)
                        .frame(minWidth: 300)
                    
                    // Preview
                    if appState.showPreview {
                        MarkdownPreview(markdown: document.text)
                            .frame(minWidth: 300)
                    }
                }
            }
            
            // Focus mode overlay
            if appState.isFocusMode {
                FocusModeOverlay()
            }
        }
        .overlay(alignment: .trailing) {
            // Sidebar views
            HStack(spacing: 0) {
                if appState.showOutline {
                    DocumentOutlineView(markdown: document.text)
                        .frame(width: 250)
                        .background(Color(NSColor.controlBackgroundColor))
                        .transition(.move(edge: .trailing))
                }
                
                if appState.showStatistics {
                    WritingStatisticsView(text: document.text)
                        .frame(width: 200)
                        .background(Color(NSColor.controlBackgroundColor))
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.easeInOut, value: appState.showOutline)
            .animation(.easeInOut, value: appState.showStatistics)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                // View mode buttons
                Button(action: { appState.showPreview.toggle() }) {
                    Label("Toggle Preview", systemImage: appState.showPreview ? "rectangle.split.2x1" : "rectangle")
                }
                .help("Toggle preview pane")
                
                Button(action: { appState.isWYSIWYGMode.toggle() }) {
                    Label("WYSIWYG Mode", systemImage: "pencil.circle")
                }
                .help("Toggle WYSIWYG mode")
                
                Button(action: { appState.isFocusMode.toggle() }) {
                    Label("Focus Mode", systemImage: "target")
                }
                .help("Toggle focus mode")
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                // Feature buttons
                Button(action: { appState.showOutline.toggle() }) {
                    Label("Outline", systemImage: "list.bullet.indent")
                }
                .help("Show document outline")
                
                Button(action: { appState.showStatistics.toggle() }) {
                    Label("Statistics", systemImage: "chart.bar")
                }
                .help("Show writing statistics")
                
                Button(action: { preferences.grammarCheckEnabled.toggle() }) {
                    Label("Grammar Check", systemImage: "checkmark.circle")
                }
                .foregroundColor(preferences.grammarCheckEnabled ? .accentColor : .secondary)
                .help("Toggle grammar checking")
                
                Button(action: { preferences.autoSaveEnabled.toggle() }) {
                    Label("Auto-save", systemImage: "arrow.triangle.2.circlepath")
                }
                .foregroundColor(preferences.autoSaveEnabled ? .accentColor : .secondary)
                .help("Toggle auto-save")
                
                Button(action: { appState.showAISettings = true }) {
                    Label("AI Assistant", systemImage: "sparkles")
                }
                .help("AI writing assistant")
            }
        }
        .sheet(isPresented: $appState.showAISettings) {
            AISettingsView()
        }
        .sheet(isPresented: $appState.showLinkDialog) {
            LinkInsertionView()
        }
        .onAppear {
            setupFormatActions()
        }
    }
    
    private func setupFormatActions() {
        // These would be connected to the actual editor
        appState.formatBold = {
            // Insert **bold** markdown
        }
        appState.formatItalic = {
            // Insert *italic* markdown
        }
        // etc...
    }
}

// Placeholder views for features
struct WYSIWYGView: View {
    @Binding var document: MarkdownDocument
    
    var body: some View {
        Text("WYSIWYG Editor")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FocusModeOverlay: View {
    var body: some View {
        Color.black.opacity(0.3)
            .allowsHitTesting(false)
    }
}

struct DocumentOutlineView: View {
    let markdown: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Document Outline")
                .font(.headline)
                .padding()
            
            List {
                // Parse headings from markdown
                ForEach(parseHeadings(from: markdown), id: \.self) { heading in
                    Text(heading)
                        .padding(.leading, CGFloat(headingLevel(heading)) * 10)
                }
            }
        }
    }
    
    private func parseHeadings(from markdown: String) -> [String] {
        // Simple heading extraction
        markdown.components(separatedBy: .newlines)
            .filter { $0.hasPrefix("#") }
            .map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    private func headingLevel(_ heading: String) -> Int {
        heading.prefix(while: { $0 == "#" }).count
    }
}

struct WritingStatisticsView: View {
    let text: String
    
    var wordCount: Int {
        text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
    }
    
    var characterCount: Int {
        text.count
    }
    
    var readingTime: Int {
        max(1, wordCount / 200) // 200 words per minute average
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Writing Statistics")
                .font(.headline)
            
            Divider()
            
            StatRow(label: "Words", value: "\(wordCount)")
            StatRow(label: "Characters", value: "\(characterCount)")
            StatRow(label: "Reading Time", value: "\(readingTime) min")
        }
        .padding()
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct LinkInsertionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var linkText = ""
    @State private var linkURL = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Insert Link")
                .font(.headline)
            
            TextField("Link Text", text: $linkText)
                .textFieldStyle(.roundedBorder)
            
            TextField("URL", text: $linkURL)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Insert") {
                    // Insert [linkText](linkURL) into editor
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(linkText.isEmpty || linkURL.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }
}

struct AISettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("AI Settings")
                .font(.headline)
            
            // AI provider selection and settings
            
            Button("Done") {
                dismiss()
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}