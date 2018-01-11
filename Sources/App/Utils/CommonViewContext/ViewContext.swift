import Foundation

protocol ViewContextRepresentable {
    var common: CommonViewContext? { get set }
}

typealias ViewContext = ViewContextRepresentable & Encodable
