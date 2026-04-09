import SwiftUI

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
}

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var newTask: String = ""

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text("📝 Sticky Note")
                    .font(.headline)
                    .foregroundColor(.white)

                TextField("Enter new task", text: $newTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        if !newTask.trimmingCharacters(in: .whitespaces).isEmpty {
                            tasks.append(Task(title: newTask))
                            newTask = ""
                            saveTasks()
                        }
                    }

                List {
                    ForEach($tasks) { $task in
                        HStack {
                            Button(action: {
                                task.isCompleted.toggle()
                                saveTasks()
                            }) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            Text(task.title)
                                .strikethrough(task.isCompleted)
                                .foregroundColor(task.isCompleted ? .gray : .white)
                        }
                        .listRowBackground(Color.clear)
                        .contextMenu {
                            Button(role: .destructive) {
                                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                                    tasks.remove(at: index)
                                    saveTasks()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { indices in
                        tasks.remove(atOffsets: indices)
                        saveTasks()
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .padding()
            .background(Color.clear)

            // Manually placed close button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .imageScale(.large)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 8)
            .padding(.trailing, 8)
        }
        .frame(width: 250, height: 300)
        .background(Color.clear)
        .onAppear {
            loadTasks()
        }
    }

    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "saved_tasks")
        }
    }

    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "saved_tasks") {
            if let decoded = try? JSONDecoder().decode([Task].self, from: data) {
                tasks = decoded
            }
        }
    }
}
