# Vapor-Template
A starting point for all of my Vapor projects

You are welcome to use this for your projects as well. It is already setup for MySQL use, and comes with `User` and `Session` classes preinstalled. You can modify it to how you deem fit, but I've found that this setup works really well for me.

# Deployment
You can deploy this template to Heroku really easily (either use the CLI or the online GUI). It's already setup to work with JawsDB MySQL.

# Vapor Usage
To clone this template to a new Vapor project, do this: `vapor new Template-Testing --template=https://github.com/mcdappdev/Vapor-Template` This is a little wordy and annoying to type out, though, in my opinion. So I added the following function to my `.zshrc` file:

```bash
nv () {
    vapor new $1 --template=https://github.com/mcdappdev/Vapor-Template
    cd $1
    vapor xcode -y
}
```

So now I just call `nv project_name`, and it creates it using the template, cd's into the directory, and builds an Xcode project for it.
