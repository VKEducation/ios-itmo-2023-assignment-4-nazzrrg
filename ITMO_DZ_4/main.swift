import Foundation
// For testing array
//var ff = ThreadSafeArray<Int>([1, 2, 3])
//var dd = [1, 2, 3]
//let g = DispatchGroup()
//g.enter()
//DispatchQueue.global(qos: .userInteractive).async {
//    for i in 0..<1000000 {
//        ff.insert(-1, at: 1)
//        if i % 10000 == 0 {
//            print("1: \(i/10000)%")
//        }
//    }
//    g.leave()
//}
//g.enter()
//DispatchQueue.global(qos: .userInteractive).async {
//    for i in 0..<1000000 {
//        ff.append(0)
//        if i % 10000 == 0 {
//            print("2: \(i/10000)%")
//        }
//    }
//    g.leave()
//}
//g.enter()
//DispatchQueue.global(qos: .userInteractive).async {
//    for _ in 0..<1000000 {
//        dd.append(-1)
//    }
//    for _ in 0..<1000000 {
//        dd.append(0)
//    }
//    g.leave()
//}
//
//g.wait()
//print(ff.endIndex == dd.endIndex)
//print(ff.sorted().elementsEqual(dd.sorted()))
//
//g.enter()
//DispatchQueue.global(qos: .userInteractive).async {
//    for i in 0..<100000 {
//        ff.removeFirst()
//        if i % 1000 == 0 {
//            print("3: \(i/1000)%")
//        }
//    }
//    g.leave()
//}
//g.enter()
//DispatchQueue.global(qos: .userInteractive).async {
//    for i in 0..<100000 {
//        ff.removeLast()
//        if i % 1000 == 0 {
//            print("4: \(i/1000)%")
//        }
//    }
//    g.leave()
//}
//g.enter()
//DispatchQueue.global(qos: .userInteractive).async {
//    for _ in 0..<200000 {
//        dd.removeFirst()
//    }
//    g.leave()
//}
//
//g.wait()
//print(ff.endIndex == dd.endIndex)

// For testing task manager
// 1, 2, 3, 4, 5, 6, 7, 8
var tm = TaskManager()
var task3_1 = TaskItem(priority: 3) { print(2) }
var task3_2 = TaskItem(priority: 5) { print(3) }
var task3 = TaskItem(priority: 1) { print(4) }
task3.addDependency(task3_2)
task3.addDependency(task3_1)

var task4 = TaskItem(priority: 1) { print(1) }
var task5 = TaskItem(priority: 5) { print(5) }
var task6 = TaskItem(priority: 6) { print(6) }
var task7 = TaskItem(priority: 6) { print(7) }
var task8 = TaskItem(priority: 10) { print(8) }

tm.add(task6)
tm.add(task5)
tm.add(task3)
tm.add(task4)
tm.add(task8)
tm.add(task7)

for _ in 0..<1000 {
    tm.runNext()
}

RunLoop.current.run()
