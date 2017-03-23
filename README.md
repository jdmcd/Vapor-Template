# Vapor-Template
A starting point for all of my Vapor projects

You are welcome to use this for your projects as well. It is already setup for MySQL and Redis use, and comes with `User` and `Token` classes preinstalled. You can modify it to how you see fit, but I've found that this setup works really well for me.

# Features
The template comes with the following features:

* Implementation of the `Auth` class, for both the frontend and an API component
* Usage of `Bearer` for authentication based off of the `Token` class
* Redis to manage the caching of session tokens
* Node's Flash library
* Views and routes split up into controllers
* Testing (Ongoing)
* Custom middleware
* A seeding function (credit: vzsg)

# Redis
Please follow the Vapor instructions for setting up Redis. You need to have the local server running for the app to even start

# Deployment
You can deploy this template to Heroku really easily (either use the CLI or the online GUI). It's already setup to work with JawsDB MySQL. You'll need to hardcode your Redis keys into the production file, at this time.

# Vapor Usage
To clone this template to a new Vapor project, do this: `vapor new HelloWorld --template=https://github.com/mcdappdev/Vapor-Template` This is a little wordy and annoying to type out, so I added the following function to my `.zshrc` file:

```bash
nv () {
    vapor new $1 --template=https://github.com/mcdappdev/Vapor-Template
}
```

So now I just call `nv HelloWorld`, and it creates it using the template. Before running this template in development mode, you need to add a `secrets` folder to the `Config` directory that has a `mysql.json` file and a `redis.json` file.

# Command Line Tool
I am currently working on a command line tool that will automate the setup the template, as well as renaming the hardcoded "CHANGEME" in `Package.swift`, and automatically fills in MySQL and Redis credentials. Stay tuned.
