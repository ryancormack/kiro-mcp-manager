import Foundation

enum SettingType {
    case bool
    case string
    case number
    case stringArray
    case picker
}

struct ArrayPreset: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

struct PickerOption {
    let value: String
    let label: String
}

struct SettingDefinition {
    let key: String
    let label: String
    let type: SettingType
    let category: String
    let hint: String
    let presets: [ArrayPreset]
    let options: [PickerOption]
    
    init(key: String, label: String, type: SettingType, category: String, hint: String, presets: [ArrayPreset] = [], options: [PickerOption] = []) {
        self.key = key
        self.label = label
        self.type = type
        self.category = category
        self.hint = hint
        self.presets = presets
        self.options = options
    }
}

let knownSettings: [SettingDefinition] = [
    // Privacy
    SettingDefinition(key: "telemetry.enabled", label: "Telemetry", type: .bool, category: "Privacy", hint: "Enable/disable telemetry collection"),
    SettingDefinition(key: "cleanup.periodDays", label: "Cleanup Period (days)", type: .number, category: "Privacy", hint: "Automatically delete old conversations, sessions, and knowledge bases after this many days"),
    
    // Chat
    SettingDefinition(key: "chat.defaultModel", label: "Default Model", type: .string, category: "Chat", hint: "Default AI model for conversations"),
    SettingDefinition(key: "chat.defaultAgent", label: "Default Agent", type: .string, category: "Chat", hint: "Default agent configuration"),
    SettingDefinition(key: "chat.diffTool", label: "Diff Tool", type: .string, category: "Chat", hint: "External diff tool for viewing code changes"),
    SettingDefinition(key: "chat.greeting.enabled", label: "Show Greeting", type: .bool, category: "Chat", hint: "Show greeting message on chat start"),
    SettingDefinition(key: "chat.editMode", label: "Edit Mode", type: .bool, category: "Chat", hint: "Enable edit mode for chat interface"),
    SettingDefinition(key: "chat.enableNotifications", label: "Notifications", type: .bool, category: "Chat", hint: "Enable desktop notifications"),
    SettingDefinition(key: "chat.disableMarkdownRendering", label: "Disable Markdown", type: .bool, category: "Chat", hint: "Disable markdown formatting in responses"),
    SettingDefinition(key: "chat.disableAutoCompaction", label: "Disable Auto-Compaction", type: .bool, category: "Chat", hint: "Disable automatic conversation summarization"),
    SettingDefinition(key: "compaction.excludeMessages", label: "Compaction Exclude Messages", type: .number, category: "Chat", hint: "Minimum message pairs to retain during compaction"),
    SettingDefinition(key: "compaction.excludeContextWindowPercent", label: "Compaction Exclude Context %", type: .number, category: "Chat", hint: "Minimum % of context window to retain during compaction"),
    SettingDefinition(key: "chat.enablePromptHints", label: "Prompt Hints", type: .bool, category: "Chat", hint: "Show startup hints with tips and shortcuts"),
    SettingDefinition(key: "chat.enableHistoryHints", label: "History Hints", type: .bool, category: "Chat", hint: "Show conversation history hints"),
    SettingDefinition(key: "chat.uiMode", label: "UI Mode", type: .string, category: "Chat", hint: "UI variant to use"),
    SettingDefinition(key: "chat.ui", label: "Chat UI", type: .picker, category: "Chat", hint: "Chat UI engine (tui for new TUI experience, legacy for classic interface)", options: [
        PickerOption(value: "tui", label: "TUI v2"),
        PickerOption(value: "legacy", label: "Legacy"),
    ]),
    SettingDefinition(key: "chat.enableContextUsageIndicator", label: "Context Usage Indicator", type: .bool, category: "Chat", hint: "Show context usage percentage in prompt"),
    SettingDefinition(key: "chat.skimCommandKey", label: "Skim Command Key", type: .string, category: "Chat", hint: "Key for fuzzy search command"),
    SettingDefinition(key: "chat.autocompletionKey", label: "Autocompletion Key", type: .string, category: "Chat", hint: "Key for autocompletion hint acceptance"),
    SettingDefinition(key: "chat.tangentModeKey", label: "Tangent Mode Key", type: .string, category: "Chat", hint: "Key for tangent mode toggle"),
    SettingDefinition(key: "chat.delegateModeKey", label: "Delegate Mode Key", type: .string, category: "Chat", hint: "Key for delegate command"),
    
    // Features
    SettingDefinition(key: "chat.enableThinking", label: "Thinking Tool", type: .bool, category: "Features", hint: "Enable thinking tool for complex reasoning"),
    SettingDefinition(key: "chat.enableTangentMode", label: "Tangent Mode", type: .bool, category: "Features", hint: "Enable tangent mode feature"),
    SettingDefinition(key: "introspect.tangentMode", label: "Introspect Tangent Mode", type: .bool, category: "Features", hint: "Auto-enter tangent mode for introspect"),
    SettingDefinition(key: "chat.enableTodoList", label: "Todo List", type: .bool, category: "Features", hint: "Enable todo list feature"),
    SettingDefinition(key: "chat.enableCheckpoint", label: "Checkpoints", type: .bool, category: "Features", hint: "Enable checkpoint feature for saving state"),
    SettingDefinition(key: "chat.enableDelegate", label: "Delegate Tool", type: .bool, category: "Features", hint: "Enable delegate tool for background tasks"),
    
    // Knowledge
    SettingDefinition(key: "chat.enableKnowledge", label: "Knowledge Base", type: .bool, category: "Knowledge", hint: "Enable knowledge base functionality"),
    SettingDefinition(key: "knowledge.defaultIncludePatterns", label: "Include Patterns", type: .stringArray, category: "Knowledge", hint: "Default file patterns to include when indexing", presets: [
        ArrayPreset(label: "Rust", value: "*.rs"),
        ArrayPreset(label: "Python", value: "**/*.py"),
        ArrayPreset(label: "JavaScript", value: "**/*.js"),
        ArrayPreset(label: "TypeScript", value: "**/*.ts"),
        ArrayPreset(label: "Markdown", value: "**/*.md"),
        ArrayPreset(label: "Text", value: "**/*.txt"),
    ]),
    SettingDefinition(key: "knowledge.defaultExcludePatterns", label: "Exclude Patterns", type: .stringArray, category: "Knowledge", hint: "Default file patterns to exclude when indexing", presets: [
        ArrayPreset(label: "target/", value: "target/**"),
        ArrayPreset(label: "node_modules/", value: "node_modules/**"),
        ArrayPreset(label: "__pycache__/", value: "__pycache__/**"),
        ArrayPreset(label: ".git/", value: ".git/**"),
    ]),
    SettingDefinition(key: "knowledge.maxFiles", label: "Max Files", type: .number, category: "Knowledge", hint: "Maximum files for indexing"),
    SettingDefinition(key: "knowledge.chunkSize", label: "Chunk Size", type: .number, category: "Knowledge", hint: "Text chunk size for processing"),
    SettingDefinition(key: "knowledge.chunkOverlap", label: "Chunk Overlap", type: .number, category: "Knowledge", hint: "Overlap between text chunks"),
    SettingDefinition(key: "knowledge.indexType", label: "Index Type", type: .picker, category: "Knowledge", hint: "Type of knowledge index", options: [
        PickerOption(value: "Fast", label: "Fast (BM25)"),
        PickerOption(value: "Best", label: "Best (Semantic)"),
    ]),
    
    // API
    SettingDefinition(key: "api.timeout", label: "API Timeout (sec)", type: .number, category: "API", hint: "API request timeout in seconds"),
    
    // MCP
    SettingDefinition(key: "mcp.initTimeout", label: "Init Timeout (sec)", type: .number, category: "MCP", hint: "MCP server initialization timeout"),
    SettingDefinition(key: "mcp.noInteractiveTimeout", label: "Non-Interactive Timeout (sec)", type: .number, category: "MCP", hint: "Non-interactive MCP timeout"),
]

let settingCategories = ["Privacy", "Chat", "Features", "Knowledge", "API", "MCP"]
