import Vapor

//Function to setup views
func loadViews(_ drop: Droplet) throws {
    MarketingViewController(drop: drop).addRoutes()
    LoginRegistrationController(drop: drop).addRoutes()
}
