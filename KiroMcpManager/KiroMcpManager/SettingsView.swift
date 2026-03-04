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
            }
        }
        .padding(.vertical, 4)
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
