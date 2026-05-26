import Foundation

struct Mapping: Codable, Identifiable, Equatable {
    var id: Int
    var name: String
    var icon: String
    var colorHex: String
}

extension Mapping {
    static let defaults: [Mapping] = [
        Mapping(id: 0, name: "아침 운동",  icon: "figure.run",            colorHex: "#E8A020"),
        Mapping(id: 1, name: "물 마시기",  icon: "drop.fill",             colorHex: "#5A7A8F"),
        Mapping(id: 2, name: "독서 30분",  icon: "book.fill",             colorHex: "#8B6F52"),
        Mapping(id: 3, name: "명상",      icon: "figure.mind.and.body",  colorHex: "#7A8F5A"),
        Mapping(id: 4, name: "비타민",    icon: "pills.fill",            colorHex: "#C8546A"),
        Mapping(id: 5, name: "",         icon: "leaf.fill",             colorHex: "#A67C52"),
        Mapping(id: 6, name: "",         icon: "pencil",                colorHex: "#9E9488"),
    ]
}
