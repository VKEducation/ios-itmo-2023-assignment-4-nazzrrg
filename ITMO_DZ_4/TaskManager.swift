import Foundation

protocol Task {
    var priority: Int { get }
    var dependencies: Array<Task> { get }
    var body: () -> Void { get }

    mutating func addDependency(_ task: Task)
}

// Dependencies are evaluated on insert into TaskManager
// Structs are copied => no way dependencies of an inserted task will be changed after insertion
struct TaskItem: Task {
    var priority: Int
    var dependencies: Array<Task>
    var body: () -> Void
    
    init (priority: Int, body: @escaping () -> Void) {
        self.priority = priority
        self.dependencies = Array<Task>()
        self.body = body
    }
    
    mutating func addDependency(_ task: Task) {
        dependencies.append(task)
    }
}

// TaskManager is thread-safe and can be accessed from any thread
class TaskManager {
    private var tasks = ThreadSafeArray<Task>()
    
    func add(_ newTask: Task) -> Void {
        tasks.findAndInsert(contentsOf: unwrapDependencies(newTask), atFirstWhere: { task in task.priority > newTask.priority }, or: tasks.endIndex)
    }
    
    func runNext() {
        tasks.popFirst()?.body()
    }
    
    private func unwrapDependencies(_ task: Task) -> [Task] {
        let deps = task.dependencies.sorted(by: { task1, task2 in task1.priority < task2.priority })
        var result = Array<Task>()
        for dep in deps {
            result.append(contentsOf: unwrapDependencies(dep)) // deps add themselves after own dependencies in unwrapDependencies
        }
        result.append(task)
        return result
    }
}
