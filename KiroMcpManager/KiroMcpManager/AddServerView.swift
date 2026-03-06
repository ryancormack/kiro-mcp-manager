import SwiftUI

struct AddServerView: View {
    @Bindable var manager: MCPConfigManager
    @Environment(\.dismiss) private var dismiss

    @State private var mode = 0 // 0 = Manual, 1 = Quick Add
    @State private var serverType = 0 // 0 = stdio, 1 = HTTP
    @State private var serverName = ""

    // Manual stdio fields
    @State private var command = ""
    @State private var argsString = ""
    @State private var envPairs: [(key: String, value: String)] = [("", "")]

    // Manual HTTP fields
    @State private var url = ""
    @State private var headerPairs: [(key: String, value: String)] = [("", "")]

    // Quick Add
    @State private var selectedPreset: QuickAddPreset?
    @State private var presetInputs: [String: String] = [:]

    // Validation
    @State private var validationError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Server")
                .font(.headline)
                .padding(.bottom, 4)

            Picker("", selection: $mode) {
                Text("Manual").tag(0)
                Text("Quick Add").tag(1)
            }
            .pickerStyle(.segmented)

            Divider()

            if mode == 0 {
                manualModeView
            } else {
                quickAddModeView
            }

            if let error = validationError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Divider()

            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                Button("Add Server") {
                    addServer()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(width: 380)
    }

    // MARK: - Manual Mode

    private var manualModeView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("Type", selection: $serverType) {
                Text("stdio").tag(0)
                Text("HTTP").tag(1)
            }
            .pickerStyle(.segmented)

            LabeledTextField(label: "Server Name", text: $serverName, placeholder: "my-server")

            if serverType == 0 {
                stdioFieldsView
            } else {
                httpFieldsView
            }
        }
    }

    private var stdioFieldsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            LabeledTextField(label: "Command", text: $command, placeholder: "node")
            LabeledTextField(label: "Args (comma-separated)", text: $argsString, placeholder: "server.js, --port, 3000")

            Text("Environment Variables")
                .font(.callout)
                .foregroundStyle(.secondary)
            KeyValueEditor(pairs: $envPairs, keyPlaceholder: "KEY", valuePlaceholder: "value")
        }
    }

    private var httpFieldsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            LabeledTextField(label: "URL", text: $url, placeholder: "https://example.com/mcp")

            Text("Headers")
                .font(.callout)
                .foregroundStyle(.secondary)
            KeyValueEditor(pairs: $headerPairs, keyPlaceholder: "Header", valuePlaceholder: "value")
        }
    }

    // MARK: - Quick Add Mode

    private var quickAddModeView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(quickAddPresets) { preset in
                Button(action: { selectPreset(preset) }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(preset.name)
                                .fontWeight(.medium)
                            Text(preset.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if selectedPreset?.id == preset.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            }

            if let preset = selectedPreset {
                Divider()
                ForEach(preset.requiredFields) { field in
                    LabeledTextField(
                        label: field.label,
                        text: presetInputBinding(for: field.key),
                        placeholder: field.placeholder
                    )
                }
            }
        }
    }

    // MARK: - Actions

    private func selectPreset(_ preset: QuickAddPreset) {
        selectedPreset = preset
        presetInputs = [:]
        for field in preset.requiredFields {
            presetInputs[field.key] = field.defaultValue
        }
    }

    private func presetInputBinding(for key: String) -> Binding<String> {
        Binding(
            get: { presetInputs[key] ?? "" },
            set: { presetInputs[key] = $0 }
        )
    }

    private func addServer() {
        validationError = nil

        if mode == 0 {
            addManualServer()
        } else {
            addPresetServer()
        }
    }

    private func addManualServer() {
        let trimmedName = serverName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            validationError = "Server name is required."
            return
        }
        if manager.serverExists(name: trimmedName) {
            validationError = "A server named \"\(trimmedName)\" already exists."
            return
        }

        if serverType == 0 {
            let trimmedCommand = command.trimmingCharacters(in: .whitespaces)
            guard !trimmedCommand.isEmpty else {
                validationError = "Command is required for stdio servers."
                return
            }

            var fields: [String: AnyCodableValue] = [
                "command": .string(trimmedCommand),
                "disabled": .bool(false),
                "type": .string("stdio")
            ]

            let args = argsString
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            if !args.isEmpty {
                fields["args"] = .array(args.map { .string($0) })
            }

            let env = buildDictionary(from: envPairs)
            if !env.isEmpty {
                fields["env"] = .object(env.mapValues { .string($0) })
            }

            manager.addServer(name: trimmedName, server: McpServer(fields: fields))
        } else {
            let trimmedURL = url.trimmingCharacters(in: .whitespaces)
            guard !trimmedURL.isEmpty else {
                validationError = "URL is required for HTTP servers."
                return
            }

            var fields: [String: AnyCodableValue] = [
                "url": .string(trimmedURL),
                "disabled": .bool(false),
                "type": .string("http")
            ]

            let headers = buildDictionary(from: headerPairs)
            if !headers.isEmpty {
                fields["headers"] = .object(headers.mapValues { .string($0) })
            }

            manager.addServer(name: trimmedName, server: McpServer(fields: fields))
        }

        dismiss()
    }

    private func addPresetServer() {
        guard let preset = selectedPreset else {
            validationError = "Please select a preset."
            return
        }

        for field in preset.requiredFields {
            let value = (presetInputs[field.key] ?? "").trimmingCharacters(in: .whitespaces)
            if value.isEmpty {
                validationError = "\(field.label) is required."
                return
            }
        }

        let trimmedName = (presetInputs["serverName"] ?? "").trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            validationError = "Server name is required."
            return
        }
        if manager.serverExists(name: trimmedName) {
            validationError = "A server named \"\(trimmedName)\" already exists."
            return
        }

        let server = preset.buildServer(presetInputs)
        manager.addServer(name: trimmedName, server: server)
        dismiss()
    }

    private func buildDictionary(from pairs: [(key: String, value: String)]) -> [String: String] {
        var result: [String: String] = [:]
        for pair in pairs {
            let k = pair.key.trimmingCharacters(in: .whitespaces)
            let v = pair.value.trimmingCharacters(in: .whitespaces)
            if !k.isEmpty {
                result[k] = v
            }
        }
        return result
    }
}

// MARK: - Reusable Components

private struct LabeledTextField: View {
    let label: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.callout)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                .font(.callout)
        }
    }
}

struct KeyValueEditor: View {
    @Binding var pairs: [(key: String, value: String)]
    let keyPlaceholder: String
    let valuePlaceholder: String

    var body: some View {
        VStack(spacing: 6) {
            ForEach(pairs.indices, id: \.self) { index in
                HStack(spacing: 6) {
                    TextField(keyPlaceholder, text: Binding(
                        get: { pairs[index].key },
                        set: { pairs[index].key = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .font(.callout)

                    TextField(valuePlaceholder, text: Binding(
                        get: { pairs[index].value },
                        set: { pairs[index].value = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .font(.callout)

                    Button(action: { removePair(at: index) }) {
                        Image(systemName: "minus.circle")
                            .foregroundStyle(.red.opacity(0.7))
                    }
                    .buttonStyle(.borderless)
                    .disabled(pairs.count <= 1)
                }
            }

            HStack {
                Button(action: addPair) {
                    Label("Add", systemImage: "plus.circle")
                        .font(.callout)
                }
                .buttonStyle(.borderless)
                Spacer()
            }
        }
    }

    private func addPair() {
        pairs.append(("", ""))
    }

    private func removePair(at index: Int) {
        guard pairs.count > 1 else { return }
        pairs.remove(at: index)
    }
}
