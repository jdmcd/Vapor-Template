import Leaf

public final class IfValueIsLessThan: Tag {
    public let name = "ifLessThan"
    
    public func run(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument]) throws -> Node? {
        return nil
    }
    
    public func shouldRender(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument], value: Node?) -> Bool {
        guard
            arguments.count == 2,
            let firstNumber = arguments[0].value?.int,
            let secondNumber = arguments[1].value?.string
            else { return false }
        return firstNumber < Int(secondNumber)!
    }
}
