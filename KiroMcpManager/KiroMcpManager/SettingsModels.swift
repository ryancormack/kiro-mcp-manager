import Foundation

enum SettingType {
    case bool
    case string
    case number
}

struct SettingDefinition {
    let key: String
    let label: String
    let type: SettingType
    let category: String
    let hint: String
}

let knownSettings: [SettingDefinition] = [
    // Telemetry
    SettingDefinition(key: "telemetry.enabled", label: "Telemetry", type: .bool, category: "Privacy", hint: "Enable/disable telemetry collection"),
    
    // Chat
    SettingDefinition(key: "chat.defaultModel", label: "Default Model", type: .string, category: "Chat", hint: "Default AI model for conversations"),
    SettingDefinition(key: "chat.greeting.enabled", label: "Show Greeting", type: .bool, category: "Chat", hint: "Show greeting message on chat start"),
    SettingDefinition(key: "chat.enableNotifications", label: "Notifications", type: .bool, category: "Chat", hint: "Enable desktop notifications"),
    SettingDefinition(key: "chat.disableMarkdownRendering", label: "Disable Markdown", type: .bool, category: "Chat", hint: "Disable markdown formatting in responses"),
    SettingDefinition(key: "chat.disableAutoCompaction", label: "Disable Auto-Compaction", type: .bool, category: "Chat", hint: "Disable automatic conversation summarization"),
    SettingDefinition(key: "chat.enablePromptHints", label: "Prompt Hints", type: .bool, category: "Chat", hint: "Show startup hints with tips and shortcuts"),
    SettingDefinition(key: "chat.enableHistoryHints", label: "History Hints", type: .bool, category: "Chat", hint: "Show conversation history hints"),
    
    // Features
    SettingDefinition(key: "chat.enableThinking", label: "Thinking Tool", type: .bool, category: "Features", hint: "Enable thinking tool for complex reasoning"),
    SettingDefinition(key: "chat.enableTangentMode", label: "Tangent Mode", type: .bool, category: "Features", hint: "Enable tangent mode for side conversations"),
    SettingDefinition(key: "chat.enableTodoList", label: "Todo List", type: .bool, category: "Features", hint: "Enable todo list feature"),
    SettingDefinition(key: "chat.enableCheckpoint", label: "Checkpoints", type: .bool, category: "Features", hint: "Enable checkpoint feature for saving state"),
    SettingDefinition(key: "chat.enableDelegate", label: "Delegate Tool", type: .bool, category: "Features", hint: "Enable delegate tool for background tasks"),
    
    // Knowledge
    SettingDefinition(key: "chat.enableKnowledge", label: "Knowledge Base", type: .bool, category: "Knowledge", hint: "Enable knowledge base functionality"),
    SettingDefinition(key: "knowledge.maxFiles", label: "Max Files", type: .number, category: "Knowledge", hint: "Maximum files for indexing"),
    SettingDefinition(key: "knowledge.chunkSize", label: "Chunk Size", type: .number, category: "Knowledge", hint: "Text chunk size for processing"),
    
    // API
    SettingDefinition(key: "api.timeout", label: "API Timeout (sec)", type: .number, category: "API", hint: "API request timeout in seconds"),
    
    // MCP
    SettingDefinition(key: "mcp.initTimeout", label: "Init Timeout (sec)", type: .number, category: "MCP", hint: "MCP server initialization timeout"),
]

let settingCategories = ["Privacy", "Chat", "Features", "Knowledge", "API", "MCP"]
