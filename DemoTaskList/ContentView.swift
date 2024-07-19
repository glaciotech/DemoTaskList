//
//  ContentView.swift
//  DemoTaskList
//
//  Created by Peter Liddle on 6/27/24.
//

import SwiftUI

struct TaskList: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    
    init(_ name: String) {
        self.name = name
    }
}


struct TaskItem: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    
    init(_ name: String) {
        self.name = name
    }
}

struct MockData {
    static let improveTasks = [
        "Paint the living room walls",
        "Install new kitchen backsplash",
        "Fix leaky bathroom faucet",
        "Clean out the garage",
        "Build a garden shed",
        "Replace old carpet with hardwood flooring",
        "Upgrade home lighting to LED"
      ]
    
    static let workProjects =  [
        "Complete quarterly financial report",
        "Develop new marketing strategy",
        "Update company website",
        "Organize team-building event",
        "Prepare for client presentation",
        "Conduct employee performance reviews",
        "Launch new product line",
        "Implement new CRM system"
      ]
    
    static let personalGoals = [
        "Start a daily exercise routine",
        "Read one book per month",
        "Learn a new language",
        "Save for a vacation",
        "Cook a new recipe each week",
        "Volunteer at a local charity",
        "Improve time management skills",
        "Take up a new hobby"
      ]
    
    static let mockTasksLists = [
        "Home Improvement Projects",
        "Work Projects",
        "Personal Goals"
    ]
}

class DataStore: ObservableObject {
    
    @Published var taskLists: [TaskList] = []
    @Published var taskItemsForLists: [UUID: [TaskItem]] = [:]
    
    private func loadMockData() {
        self.taskLists = MockData.mockTasksLists.map({ .init($0) })
        self.taskItemsForLists[self.taskLists[0].id] = MockData.improveTasks.map({ .init($0) })
        self.taskItemsForLists[self.taskLists[1].id] = MockData.workProjects.map({ .init($0) })
        self.taskItemsForLists[self.taskLists[2].id] = MockData.personalGoals.map({ .init($0) })
    }

    func load() {
        loadMockData()
    }
    
    func fetchListItems(withId id: UUID) -> Binding<[TaskItem]>{
        return Binding<[TaskItem]> {
            return self.taskItemsForLists[id] ?? [TaskItem]()
        } set: { newValue in
            self.taskItemsForLists[id] = newValue
        }
    }
    
    func fetchTaskList(withPrimaryId id: UUID) -> Binding<TaskList>{
        return Binding<TaskList> {
            return self.taskLists.filter({ $0.id == id }).first ?? TaskList("")
        } set: { newValue in
            guard let index = self.taskLists.firstIndex(where: { $0.id == id }) else {
                return
            }
            self.taskLists[index] = newValue
        }
    }
    
    func deleteTask(listId: UUID, taskId: UUID) {
        taskItemsForLists[listId]?.removeAll(where: { $0.id == taskId })
    }
}

struct EditableTextField: View {
    
    var placeholder: String
    @Binding var text: String
    @State private var editing: Bool
    var deleteCallback: (() -> Void)?
    
    @FocusState var isFocused: Bool
    
    init(_ placeholder: String, text: Binding<String>, editing: Bool = false, deleteCallback: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self._text = text
        self.deleteCallback = deleteCallback
        self.editing = editing
    }
    
    var body: some View {
        HStack {
        
#if os(macOS)
            Button {
                editing.toggle()
                isFocused.toggle()
            } label: {
                editing ? Image(systemName: "checkmark") : Image(systemName: "square.and.pencil")
            }
            .accessibilityIdentifier(editing ? "complete edit" : "edit")
#endif
            if editing {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .accessibilityIdentifier("New Task Input")
            }
            else {
                Text(text)
            }
                
#if os(iOS)
            if editing {
                Button {
                    editing = false
                    isFocused = false
                } label: {
                    Image(systemName: "checkmark")
                        .accessibilityIdentifier("complete edit")
                }
            }
#else
            Spacer()
            
            if let _ = deleteCallback {
                Button {
                    deleteCallback!()
                } label: {
                    Image(systemName: "trash")
                        .tint(.red)
                }
            }
#endif
        }
        
#if os(iOS)
        .swipeActions(edge: .trailing) {
            Button(action: {
                editing = true
            }) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)

            Button(role: .destructive) {
                deleteCallback?()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
#endif
        
        .onAppear {
            if self.editing {
                isFocused = true
            }
        }
    }
}

struct TaskListView: View {
    
    @EnvironmentObject var dataStore: DataStore
    var selectedList: UUID
    @State var currentlyEditing: UUID? = nil
    
    var body: some View {
        let item = dataStore.fetchTaskList(withPrimaryId: selectedList)
        VStack {
            HStack {
#if os(macOS)
                EditableTextField("Task List Name", text: item.name)
#endif
            }
#if os(iOS)
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
#endif
            List {
                ForEach(dataStore.fetchListItems(withId: selectedList)) { item in
                    EditableTextField("Task Name", text: item.name, editing: currentlyEditing == item.id) {
                        dataStore.deleteTask(listId: selectedList, taskId: item.id)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Button("Add") {
                    let newTask = TaskItem("")
                    dataStore.fetchListItems(withId: selectedList).wrappedValue.append(newTask)
                    currentlyEditing = newTask.id
                }
                .tint(Color.blue)
            }
        }
#if os(macOS)
        .padding(25)
#endif
    }
}

struct ContentView: View {
    
    @AppStorage("tasks") private var tasksData: Data = Data()
    
    @ObservedObject var dataStore = DataStore()
    @State var selectedList: UUID? = UUID() // We have to make this optional to support iOS
    
    
    var body: some View {
        
        NavigationSplitView {
            List(selection: $selectedList) {
                ForEach(dataStore.taskLists) { list in
                    Text(list.name)
                }
            }
        } detail: {
            if let selectedList = selectedList {
                TaskListView(selectedList: selectedList)
                    .environmentObject(dataStore)
            }
            else {
                EmptyView()
            }
        }
        .onAppear {
            dataStore.load()
            selectedList = dataStore.taskLists[0].id
        }
#if os(macOS)
        .padding()
#endif

    }
}

#Preview {
    ContentView()
}
