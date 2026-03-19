import SwiftUI

struct SettingsSection: View {
    @Bindable var manager: SettingsManager
    @State private var expandedCategories: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(settingCategories, id: \.self) { category in
                CategoryRow(
                    category: category,
                    isExpanded: expandedCategories.contains(category),
                    onToggle: { toggleCategory(category) },
                    settings: knownSettings.filter { $0.category == category },
                    manager: manager
                )
            }
        }
    }
    
    private func toggleCategory(_ category: String) {
        if expandedCategories.contains(category) {
            expandedCategories.remove(category)
        } else {
            expandedCategories.insert(category)
        }
    }
}

private struct CategoryRow: View {
    let category: String
    let isExpanded: Bool
    let onToggle: () -> Void
    let settings: [SettingDefinition]
    @Bindable var manager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.callout)
                        .frame(width: 16)
                    Text(category)
                        .fontWeight(.medium)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(settings, id: \.key) { setting in
                        SettingRow(setting: setting, manager: manager)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.leading, 16)
                .padding(.bottom, 10)
            }
        }
    }
}

private struct SettingRow: View {
    let setting: SettingDefinition
    @Bindable var manager: SettingsManager
    
    var body: some View {
        if setting.type == .stringArray {
            VStack(alignment: .leading, spacing: 6) {
                Text(setting.label)
                    .font(.callout)
                    .help(setting.hint)
                ArraySettingControl(key: setting.key, presets: setting.presets, manager: manager)
            }
            .padding(.vertical, 6)
        } else {
            HStack {
                Text(setting.label)
                    .font(.callout)
                    .help(setting.hint)
                Spacer()
                
                switch setting.type {
                case .bool:
                    BoolSettingControl(key: setting.key, manager: manager)
                case .string:
                    StringSettingControl(key: setting.key, manager: manager)
                case .number:
                    NumberSettingControl(key: setting.key, manager: manager)
                case .picker:
                    PickerSettingControl(key: setting.key, options: setting.options, manager: manager)
                case .stringArray:
                    EmptyView()
                }
            }
            .padding(.vertical, 4)
        }
    }
}

private struct BoolSettingControl: View {
    let key: String
    @Bindable var manager: SettingsManager
    
    var body: some View {
        Toggle("", isOn: Binding(
            get: { manager.getBool(for: key) ?? false },
            set: { manager.setBool($0, for: key) }
        ))
        .toggleStyle(.switch)
        .labelsHidden()
    }
}

private struct StringSettingControl: View {
    let key: String
    @Bindable var manager: SettingsManager
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField("", text: $text)
            .textFieldStyle(.roundedBorder)
            .font(.callout)
            .frame(width: 140)
            .focused($isFocused)
            .onAppear { text = manager.getString(for: key) ?? "" }
            .onChange(of: isFocused) { _, focused in
                if !focused && !text.isEmpty {
                    manager.setString(text, for: key)
                }
            }
            .onSubmit {
                if !text.isEmpty {
                    manager.setString(text, for: key)
                }
            }
    }
}

private struct NumberSettingControl: View {
    let key: String
    @Bindable var manager: SettingsManager
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField("", text: $text)
            .textFieldStyle(.roundedBorder)
            .font(.callout)
            .frame(width: 80)
            .focused($isFocused)
            .onAppear {
                if let num = manager.getNumber(for: key) {
                    text = num.truncatingRemainder(dividingBy: 1) == 0 
                        ? String(Int(num)) 
                        : String(num)
                }
            }
            .onChange(of: isFocused) { _, focused in
                if !focused, let num = Int(text) {
                    manager.setNumber(num, for: key)
                }
            }
            .onSubmit {
                if let num = Int(text) {
                    manager.setNumber(num, for: key)
                }
            }
    }
}

private struct ArraySettingControl: View {
    let key: String
    let presets: [ArrayPreset]
    @Bindable var manager: SettingsManager
    @State private var newItem: String = ""
    
    private var items: [String] { manager.getStringArray(for: key) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Current items
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red.opacity(0.7))
                                .font(.callout)
                            Text(item)
                                .font(.callout.monospaced())
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button("Remove") { remove(item) }
                                .buttonStyle(.borderless)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // Add custom
            HStack(spacing: 8) {
                TextField("Pattern…", text: $newItem)
                    .textFieldStyle(.roundedBorder)
                    .font(.callout)
                    .onSubmit { addCustom() }
                Button("Add") { addCustom() }
                    .disabled(newItem.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.top, 2)
            
            // Quick-add presets
            if !presets.isEmpty {
                let available = presets.filter { !items.contains($0.value) }
                if !available.isEmpty {
                    FlowLayout(spacing: 4) {
                        Text("Quick add:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 2)
                        ForEach(available) { preset in
                            Button(preset.label) { add(preset.value) }
                                .font(.caption)
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                        }
                    }
                }
            }
        }
    }
    
    private func addCustom() {
        let value = newItem.trimmingCharacters(in: .whitespaces)
        guard !value.isEmpty else { return }
        add(value)
        newItem = ""
    }
    
    private func add(_ value: String) {
        var current = items
        guard !current.contains(value) else { return }
        current.append(value)
        manager.setStringArray(current, for: key)
    }
    
    private func remove(_ value: String) {
        manager.setStringArray(items.filter { $0 != value }, for: key)
    }
}

private struct PickerSettingControl: View {
    let key: String
    let options: [PickerOption]
    @Bindable var manager: SettingsManager
    
    private var selection: Binding<String> {
        Binding(
            get: { manager.getString(for: key) ?? "" },
            set: {
                if $0.isEmpty {
                    manager.deleteValue(for: key)
                } else {
                    manager.setString($0, for: key)
                }
            }
        )
    }
    
    var body: some View {
        Picker("", selection: selection) {
            Text("No default").tag("")
            ForEach(options, id: \.value) { option in
                Text(option.label).tag(option.value)
            }
        }
        .labelsHidden()
        .frame(width: 140)
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 4
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var height: CGFloat = 0
        for (i, row) in rows.enumerated() {
            let rowHeight = row.map { subviews[$0].sizeThatFits(.unspecified).height }.max() ?? 0
            height += rowHeight + (i > 0 ? spacing : 0)
        }
        return CGSize(width: proposal.width ?? 0, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for (i, row) in rows.enumerated() {
            let rowHeight = row.map { subviews[$0].sizeThatFits(.unspecified).height }.max() ?? 0
            if i > 0 { y += spacing }
            var x = bounds.minX
            for idx in row {
                let size = subviews[idx].sizeThatFits(.unspecified)
                subviews[idx].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[Int]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[Int]] = [[]]
        var x: CGFloat = 0
        for (i, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if !rows[rows.count - 1].isEmpty && x + size.width > maxWidth {
                rows.append([])
                x = 0
            }
            rows[rows.count - 1].append(i)
            x += size.width + spacing
        }
        return rows
    }
}
