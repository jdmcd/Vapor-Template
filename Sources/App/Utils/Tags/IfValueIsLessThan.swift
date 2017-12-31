//import Leaf
//
//public final class IfValueIsLessThan: Tag {
//    public var name: String = "ifGreaterThan"
//
//    public func run(tagTemplate: TagTemplate, arguments: ArgumentList) throws -> Node? {
//        guard arguments.count == 2 else { throw LeafError.expectedTwoArguments(have: arguments.list)  }
//        return nil
//    }
//
//    public func shouldRender(tagTemplate: TagTemplate, arguments: ArgumentList, value: Node?) -> Bool {
//        guard
//            arguments.count == 2,
//            let firstNumber = arguments[0]?.int,
//            let secondNumber = arguments[1]?.int
//            else { return false }
//        return firstNumber < secondNumber
//    }
//}

