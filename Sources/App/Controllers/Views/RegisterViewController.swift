//import Vapor
//import BCrypt
//import Flash
//import MySQL
//import Validation
//
//final class RegisterViewController: RouteCollection {
//    private let view: ViewRenderer
//
//    init(_ view: ViewRenderer) {
//        self.view = view
//    }
//
//    func build(_ builder: RouteBuilder) throws {
//        builder.frontend(.noAuthed).group(RedirectMiddleware()) { build in
//            build.get("/register", handler: register)
//            build.post("/register", handler: handleRegisterPost)
//        }
//    }
//
//    //MARK: - GET /register
//    func register(_ req: Request) throws -> ResponseRepresentable {
//        return try view.make("register", for: req)
//    }
//
//    //MARK: - POST /register
//    func handleRegisterPost(_ req: Request) throws -> ResponseRepresentable {
//        guard let data = req.formURLEncoded else { throw Abort.badRequest }
//
//        //TODO: - Generic subscript upon Swift 4
//        guard let password = data[User.Field.password.rawValue]?.string else { throw Abort.badRequest }
//        guard let confirmPassword = data["confirmPassword"]?.string else { throw Abort.badRequest }
//
//        if password != confirmPassword {
//            return Response(redirect: "/register").flash(.error, "Passwords don't match")
//        }
//
//        var json = JSON(node: data)
//        try json.set(User.Field.password, try BCryptHasher().make(password.bytes).makeString())
//
//        do {
//            let user = try User(json: json)
//            try user.save()
//            try user.authenticate(req: req)
//            return Response(redirect: "/home")
//        } catch is MySQLError {
//            return Response(redirect: "/register").flash(.error, "Email already exists")
//        } catch is ValidationError {
//            return Response(redirect: "/register").flash(.error, "Email format is invalid")
//        } catch {
//            return Response(redirect: "/register").flash(.error, "Something went wrong")
//        }
//    }
//}
//
