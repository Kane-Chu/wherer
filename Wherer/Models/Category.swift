import Foundation

enum Category: String, CaseIterable, Identifiable {
    case clothing = "衣服"
    case document = "证件"
    case medicine = "药品"
    case electronics = "数码"
    case other = "其他"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .clothing: return "tshirt"
        case .document: return "doc.text"
        case .medicine: return "cross.case"
        case .electronics: return "cpu"
        case .other: return "cube.box"
        }
    }
}
