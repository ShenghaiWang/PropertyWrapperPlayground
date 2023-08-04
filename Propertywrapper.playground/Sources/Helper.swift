import Foundation

public func code(for title: String, run: () -> Void) {
    print("=========== Result for \(title) ===========\n")
    run()
}
