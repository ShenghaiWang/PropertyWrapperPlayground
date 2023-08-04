import Foundation
/*:
 # What is a Property?

 ## With backing store
     struct Struct {
        let property1: Int
        var property2: Int
        lazy var property2: Int = { 0 }()
     }

 ## Without backing store
     struct Struct {
        var property2: Int {
            0
        }
     }

 ## Having observer
     struct Struct {
         var value: String {
             willSet {
             }
             didSet {
             }
         }
     }

 ## Having accessor
     struct Struct {
         var value: String {
             get {
                return "value"
             }
             set {
             }
         }
     }
 */
code(for: "Property introduction") {
    struct Struct {
        var value: String {
            get {
                return "value"
            }
            set {
            }
        }
    }
    print(Struct().value)
}

/*:
 # Property wrapper

 Is a structure that encapsulates accessors of the property and adds additional behavior to it.

 Is a machenism to promote code reuse of the accessors.

 ## The simplest form
 */
code(for: "Simplest form") {
    @propertyWrapper
    struct BasicWrapper {
        let wrappedValue: String
    }

    struct DemoStruct {
        @BasicWrapper var value = "demo"
    }

    print(DemoStruct().value)
}

/*:
 ## Make it useful - Adding logic into accessors of `wrappedValue`
 */

code(for: "Clampping values") {
    @propertyWrapper
    struct Clamping {
        let range: ClosedRange<Int>
        var value: Int

        init(wrappedValue: Int, range: ClosedRange<Int>) {
            self.range = range
            self.value = wrappedValue
        }

        var wrappedValue: Int {
            get {
                min(max(range.lowerBound, value), range.upperBound)
            }
            set {
                value = newValue
            }
        }
    }

    struct DemoStruct {
        @Clamping(range: 0...100) var score = 0
    }

    print(DemoStruct().score)

    struct DemoStruct2 {
        @Clamping(range: 0...150) var mathScore = 0
        @Clamping(range: 0...100) var historyScore = 0
    }
}

/*:
 ## Practical example - Accessing UserDefault
 */

code(for: "Accessing UserDefault") {
    @propertyWrapper
    struct UserDefault<T> {
        let key: String
        let defaultValue: T

        var wrappedValue: T {
            get {
                UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
            }
            set {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }

    enum GlobalSettings {
        @UserDefault(key: "FOO_FEATURE_ENABLED", defaultValue: false)
        static var isFooFeatureEnabled: Bool

        @UserDefault(key: "BAR_FEATURE_ENABLED", defaultValue: false)
        static var isBarFeatureEnabled: Bool
    }
}

/*:
 ## Extra behavior: projectedValue
 */

code(for: "Projected Value") {
    @propertyWrapper
    struct Clamping {
        let range: ClosedRange<Int>
        var value: Int

        init(wrappedValue: Int, range: ClosedRange<Int>) {
            self.range = range
            self.value = wrappedValue
        }

        var wrappedValue: Int {
            get {
                min(max(range.lowerBound, value), range.upperBound)
            }
            set {
                value = newValue
            }
        }

        var projectedValue: Bool {
            value > range.upperBound * 6 / 10
        }
    }

    struct DemoStruct {
        @Clamping(range: 0...150) var mathScore = 80
        @Clamping(range: 0...100) var historyScore = 80
    }

    print(DemoStruct().mathScore)
    print(DemoStruct().$mathScore)

    print(DemoStruct().historyScore)
    print(DemoStruct().$historyScore)
}

/*:
 ## Usage in SwiftUI

 `@State`, `@Binding`, `@ObservedObject` are all property wrappers.

 Their projectValues are `Binding`.

 They conform to `DynamicProperty` to update View when needed
 */
