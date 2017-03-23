import Vapor
import HTTP

final class UserController: ResourceRepresentable {
    func index(request: Request) throws -> ResponseRepresentable {
        return try User.all().makeJSON()
    }
    
    func show(request: Request, user: User) throws -> ResponseRepresentable {
        return user
    }
    
    func update(request: Request, user: User) throws -> ResponseRepresentable {
        var currentUser = user
        let data = request.data
        
        if let name = data["name"]?.string {
            currentUser.name = name
        }
        
        if let email = data["email"]?.string {
            currentUser.email = email
        }
        
        try currentUser.save()
        return currentUser
    }
    
    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            show: show,
            modify: update
        )
    }
}
