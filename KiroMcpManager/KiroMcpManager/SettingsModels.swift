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
    // Telemetry and privacy
    SettingDefinition(key: "telemetry.enabled", label: "Telemetry", type: .bool, category: "Telemetry & Privacy", hint: "Enable/disable telemetry collection"),
    SettingDefinition(key: "telemetryClientId", label: "Telemetry Client ID", type: .string, category: "Telemetry & Privacy", hint: "Client identifier for telemetry"),
    
    // Chat interface
    SettingDefinition(key: "chat.defaultModel", label: "Default Model", type: .string, category: "Chat", hint: "Default AI model for conversations"),
    SettingDefinition(key: "chat.defaultAgent", label: "Default Agent", type: .string, category: "Chat", hint: "Default agent configuration"),
    SettingDefinition(key: "chat.diffTool", label: "Diff Tool", type: .string, category: "Chat", hint: "External diff tool for viewing code changes (classic only)"),
    SettingDefinition(key: "chat.greeting.enabled", label: "Show Greeting", type: .bool, category: "Chat", hint: "Show greeting message on chat start"),
    SettingDefinition(key: "chat.editMode", label: "Edit Mode", type: .bool, category: "Chat", hint: "Enable Vi edit mode (classic only)"),
    SettingDefinition(key: "chat.enableNotifications", label: "Notifications", type: .bool, category: "Chat", hint: "Enable desktop notifications"),
    SettingDefinition(key: "chat.notificationMethod", label: "Notification Method", type: .picker, category: "Chat", hint: "Notification method", options: [
        PickerOption(value: "auto", label: "Auto"),
        PickerOption(value: "bel", label: "BEL"),
        PickerOption(value: "osc9", label: "OSC9"),
    ]),
    SettingDefinition(key: "chat.disableMarkdownRendering", label: "Disable Markdown", type: .bool, category: "Chat", hint: "Disable markdown formatting (classic only)"),
    SettingDefinition(key: "chat.disableWrap", label: "Disable Wrap", type: .bool, category: "Chat", hint: "Emit chat output without hard line breaks for clean copy-paste; terminal soft-wrap still applies."),
    SettingDefinition(key: "chat.disableAutoCompaction", label: "Disable Auto-Compaction", type: .bool, category: "Chat", hint: "Disable automatic conversation summarization"),
    SettingDefinition(key: "compaction.excludeMessages", label: "Compaction Exclude Messages", type: .number, category: "Chat", hint: "Minimum message pairs to retain during compaction"),
    SettingDefinition(key: "compaction.excludeContextWindowPercent", label: "Compaction Exclude Context %", type: .number, category: "Chat", hint: "Minimum % of context window to retain during compaction"),
    SettingDefinition(key: "chat.enablePromptHints", label: "Prompt Hints", type: .bool, category: "Chat", hint: "Show startup hints with tips and shortcuts"),
    SettingDefinition(key: "chat.enableHistoryHints", label: "History Hints", type: .bool, category: "Chat", hint: "Show conversation history hints (classic only)"),
    SettingDefinition(key: "chat.uiMode", label: "UI Mode", type: .string, category: "Chat", hint: "UI variant to use"),
    SettingDefinition(key: "chat.ui", label: "Chat UI", type: .picker, category: "Chat", hint: "UI engine: tui (default) or classic", options: [
        PickerOption(value: "tui", label: "TUI"),
        PickerOption(value: "classic", label: "Classic"),
    ]),
    SettingDefinition(key: "chat.disableGranularTrust", label: "Disable Granular Trust", type: .bool, category: "Chat", hint: "Disable tiered trust options for tool approvals (terminal UI only)"),
    SettingDefinition(key: "chat.autoExpandToolOutput", label: "Auto-Expand Tool Output", type: .bool, category: "Chat", hint: "Auto-expand tool output instead of collapsing (terminal UI only)"),
    SettingDefinition(key: "chat.enableContextUsageIndicator", label: "Context Usage Indicator", type: .bool, category: "Chat", hint: "Show context usage percentage in prompt (classic only)"),
    
    // Knowledge base
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
    
    // Key bindings
    SettingDefinition(key: "chat.skimCommandKey", label: "Skim Command Key", type: .string, category: "Key Bindings", hint: "Key for fuzzy search command (classic only)"),
    SettingDefinition(key: "chat.autocompletionKey", label: "Autocompletion Key", type: .string, category: "Key Bindings", hint: "Key for autocompletion hint acceptance (classic only)"),
    SettingDefinition(key: "chat.tangentModeKey", label: "Tangent Mode Key", type: .string, category: "Key Bindings", hint: "Key for tangent mode toggle (classic only)"),
    SettingDefinition(key: "chat.delegateModeKey", label: "Delegate Mode Key", type: .string, category: "Key Bindings", hint: "Key for delegate command (classic only)"),
    SettingDefinition(key: "chat.keybindings.cancelStream", label: "Cancel Stream", type: .string, category: "Key Bindings", hint: "Cancel the current agent response while it streams"),
    SettingDefinition(key: "chat.keybindings.closeMenu", label: "Close Menu", type: .string, category: "Key Bindings", hint: "Close overlay panels and pickers"),
    SettingDefinition(key: "chat.keybindings.quit", label: "Quit", type: .string, category: "Key Bindings", hint: "Exit the chat session"),
    
    // Tool Search
    SettingDefinition(key: "toolSearch.enabled", label: "Enabled", type: .bool, category: "Tool Search", hint: "Enable Tool Search for on-demand MCP tool discovery (default: false)"),
    SettingDefinition(key: "toolSearch.minPct", label: "Min Context %", type: .number, category: "Tool Search", hint: "Activate when MCP tool specs exceed this % of context window (default: 5)"),
    SettingDefinition(key: "toolSearch.minTokens", label: "Min Tokens", type: .number, category: "Tool Search", hint: "Activate when MCP tool specs exceed this token count (default: 50000)"),
    
    // Feature toggles
    SettingDefinition(key: "chat.enableThinking", label: "Thinking Tool", type: .bool, category: "Features", hint: "Enable thinking tool for complex reasoning"),
    SettingDefinition(key: "chat.enableTangentMode", label: "Tangent Mode", type: .bool, category: "Features", hint: "Enable tangent mode feature (classic only)"),
    SettingDefinition(key: "introspect.tangentMode", label: "Introspect Tangent Mode", type: .bool, category: "Features", hint: "Auto-enter tangent mode for introspect (classic only)"),
    SettingDefinition(key: "chat.enableTodoList", label: "Todo List", type: .bool, category: "Features", hint: "Enable todo list feature (classic only)"),
    SettingDefinition(key: "chat.enableCheckpoint", label: "Checkpoints", type: .bool, category: "Features", hint: "Enable checkpoint feature (classic only)"),
    SettingDefinition(key: "chat.enableDelegate", label: "Delegate Tool", type: .bool, category: "Features", hint: "Enable delegate tool (classic only)"),
    SettingDefinition(key: "app.disableAutoupdates", label: "Disable Auto-Updates", type: .bool, category: "Features", hint: "Disable background auto-updates"),
    
    // API and service
    SettingDefinition(key: "api.timeout", label: "API Timeout (sec)", type: .number, category: "API", hint: "API request timeout in seconds"),
    
    // MCP
    SettingDefinition(key: "mcp.initTimeout", label: "Init Timeout (sec)", type: .number, category: "MCP", hint: "MCP server initialization timeout"),
    SettingDefinition(key: "mcp.noInteractiveTimeout", label: "Non-Interactive Timeout (sec)", type: .number, category: "MCP", hint: "Non-interactive MCP timeout"),
    SettingDefinition(key: "mcp.loadedBefore", label: "Loaded Before", type: .bool, category: "MCP", hint: "Track previously loaded MCP servers"),
]

let settingCategories = ["Telemetry & Privacy", "Chat", "Knowledge", "Key Bindings", "Tool Search", "Features", "API", "MCP"]
