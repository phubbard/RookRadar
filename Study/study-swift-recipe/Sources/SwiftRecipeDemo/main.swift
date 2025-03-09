import Foundation

print("Hello, Swift on Fedora!")

// Demo class to show some Swift features
class Person {
    let name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    func describe() -> String {
        return "Person named \(name), age \(age)"
    }
}

// Create and use a Person instance
let person = Person(name: "Swift Developer", age: 30)
print(person.describe())

// Show current date and time
let now = Date()
let formatter = DateFormatter()
formatter.dateStyle = .full
formatter.timeStyle = .medium
print("Current date and time: \(formatter.string(from: now))")
