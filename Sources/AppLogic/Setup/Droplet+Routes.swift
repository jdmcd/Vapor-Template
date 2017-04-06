import Vapor

//Function to setup routes
func loadRoutes(_ drop: Droplet) throws {
    LoginRegistrationControllerAPI(drop: drop).addRoutes()
}
