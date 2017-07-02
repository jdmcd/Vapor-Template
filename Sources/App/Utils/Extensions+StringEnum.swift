//The MIT License
//
//Copyright (c) 2017 Bogdan Pashchenko http://ios-engineer.com
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import Fluent

extension StructuredDataWrapper {
    func get<T, E: RawRepresentable>(_ field: E) throws -> T where E.RawValue == String {
        return try get(field.rawValue)
    }
    
    mutating func set<E: RawRepresentable>(_ field: E, _ any: Any?) throws where E.RawValue == String {
        try set(field.rawValue, any)
    }
}

extension QueryRepresentable where Self: ExecutorRepresentable {
    func filter<E: RawRepresentable>(_ field: E, _ value: NodeRepresentable?) throws -> Query<Self.E> where E.RawValue == String {
        return try filter(field.rawValue, value)
    }
}

extension Creator {
    func string<E: RawRepresentable>(_ name: E, optional: Bool = true, unique: Bool = false) where E.RawValue == String {
        string(name.rawValue, optional: optional, unique: unique)
    }
    
    func int<E: RawRepresentable>(_ name: E, optional: Bool = true, unique: Bool = false) where E.RawValue == String {
        int(name.rawValue, optional: optional, unique: unique)
    }
    
    func bool<E: RawRepresentable>(_ name: E, optional: Bool = true, unique: Bool = false) where E.RawValue == String {
        bool(name.rawValue, optional: optional, unique: unique)
    }
}
