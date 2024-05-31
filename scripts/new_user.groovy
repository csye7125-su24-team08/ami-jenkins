import jenkins.model.*

def instance = Jenkins.getInstance()

def hudsonRealm = new hudson.security.HudsonPrivateSecurityRealm(false)
instance.setSecurityRealm(hudsonRealm)

def newAdmin = hudsonRealm.createAccount("piyush", "piyush")
newAdmin.setFullName("Piyush Dongre")
newAdmin.save()

def newPiyushUser = hudsonRealm.createAccount("piyush", "piyush")
newPiyushUser.setFullName("Piyush Dongre")
newPiyushUser.save()

def newAnuraagUser = hudsonRealm.createAccount("anuraag", "anuraag")
newAnuraagUser.setFullName("Anuraag Bhatula")
newAnuraagUser.save()
