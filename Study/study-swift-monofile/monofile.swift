print("Hello from Swift on Fedora!")
print("This is a basic Swift program running in a container")

// Demo class
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

let person = Person(name: "Swift Developer", age: 30)
print(person.describe())
