import Foundation
import UIKit

struct User {
    let id: String
    let fullname: String
    let username: String
}

struct News {
    let id: String
    let image: UIImage
    let date: String
    let title: String
    let speciality: Speciality
    let description: String
    let user: User
}

struct Case {
    let id: String
    let title: String
    let description: String
    let history: String
    let examination: String
    let date: String
    let speciality: Speciality
    let user: User
}

struct Discussion {
    let id: String
    let title: String
    let description: String
    let date: String
    let speciality: Speciality
    let user: User
}

struct Research {
    let id: String
    let pdf: URL
    let date: String
    let title: String
    let speciality: Speciality
    let description: String
    let user: User
}

struct Speciality {
    let name: String
    let color: UIColor?
}
