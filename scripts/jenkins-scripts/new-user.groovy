import jenkins.model.*

def instance = Jenkins.getInstance()

def hudsonRealm = new hudson.security.HudsonPrivateSecurityRealm(false)
instance.setSecurityRealm(hudsonRealm)

// Change the user name and password to admin and admin
def newAdmin = hudsonRealm.createAccount("admin", "admin")
newAdmin.setFullName("Admin")
newAdmin.save()

def newPiyushUser = hudsonRealm.createAccount("piyush", "piyush")
newPiyushUser.setFullName("Piyush Dongre")
newPiyushUser.save()

def newAnuraagUser = hudsonRealm.createAccount("anuraag", "anuraag")
newAnuraagUser.setFullName("Anuraag Bathula")
newAnuraagUser.save()
