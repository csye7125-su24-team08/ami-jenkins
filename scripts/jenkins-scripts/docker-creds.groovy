import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import com.cloudbees.plugins.credentials.SystemCredentialsProvider

def id = 'docker-credentials'
def description = 'Docker Access Token'
def username = 'dongrep'
def password = args[0]

def credentials = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    id,
    description,
    username,
    password
)

SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), credentials)
