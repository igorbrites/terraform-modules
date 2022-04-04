@Library('jenkins-library') _

def modules = []

pipeline {
  agent {
    kubernetes {
      defaultContainer 'jnlp'
      yamlFile 'JenkinsKubernetesPod.yaml'
    }
  }

  environment {
    GH_TOKEN = credentials('ct-github-token')
    TERRAFORM_CLOUD_TOKEN = credentials('ct-terraform-module')
    TF_CLI_CONFIG_FILE = '/tmp/terraformrc'
    ORGANIZATION_NAME = 'igorbrites'
  }

  options{
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
    disableConcurrentBuilds()
  }

  stages {
    stage('Init') {
      when {
        not { buildingTag() }
      }
      steps {
        container('terraform') {
          sh label: 'Terraform credential file', script: """
          cat <<EOF > ${env.TF_CLI_CONFIG_FILE}
          credentials \"app.terraform.io\" {
            token = \"${env.TERRAFORM_CLOUD_TOKEN}\"
          }
          EOF
          """.stripIndent()
        }

        container('jnlp') {
          sh("git config remote.origin.url https://${env.GH_TOKEN}@github.com/${env.ORGANIZATION_NAME}/terraform-modules.git")
          sh('git config --global user.name "$(git log -1 --pretty=format:\'%an\')"')
          sh('git config --global user.email "$(git log -1 --pretty=format:\'%ae\')"')
          sh('git pull --tags')
        }

        container('node') {
          sh('npm ci --unsafe-perm')
          sh('apk add --no-cache jq git')
          sh('git config --global user.name "$(git log -1 --pretty=format:\'%an\')"')
          sh('git config --global user.email "$(git log -1 --pretty=format:\'%ae\')"')

          script {
            lernaModules = sh(
              returnStdout: true,
              script: "npx lerna changed --include-merged-tags --json | jq -c '[.[] | .location]'"
            ).trim()
            
            if (lernaModules == "") {
              lernaModules = '[]'
            }

            modules = readJSON(text: lernaModules)
          }
        }
      }
    }

    stage('Terraform Docs') {
      when {
        not { branch "main" }
        not { buildingTag() }
      }
      steps {
        git branch: env.GIT_BRANCH, url: "https://${env.GH_TOKEN}@github.com/${env.ORGANIZATION_NAME}/terraform-modules.git"

        script {
          def jobs = [:]

          modules.each {
            module = it - "${env.WORKSPACE}/"
            jobs[module] = {
              stage("Terraform Docs for ${module}") {
                container('terraform-docs') {
                  sh("terraform-docs -c .terraform-docs.yml ${it}")
                }

                sh("git add ${it}/README.md")
                sh("git commit -m 'docs(${module}): generating terraform-docs [skip ci]' || true")
              }
            }
          }

          parallel jobs
        }

        sh(label: "Push docs to GitHub", script: "git push -u origin ${env.GIT_BRANCH}")
      }
    }

    stage('Validation') {
      when {
        not { branch "main" }
        not { buildingTag() }
        expression { modules.size() > 0 }
      }
      environment {
        DEFAULT_BRANCH = 'main'
      }
      steps {
        script {
          def jobs = [:]
          jobs['linter'] = {
            stage('Running Super Linter') {
              container('linter') {
                sh("DEFAULT_WORKSPACE=${env.WORKSPACE} /action/lib/linter.sh")
              }
            }
          }

          modules.each {
            module = it - "${env.WORKSPACE}/"
            jobs[module] = {
              stage("Validating ${module}") {
                container('terraform') {
                  dir(it) {
                    sh('terraform init -backend=false')
                    sh('terraform fmt -check -diff')
                    sh('terraform validate -no-color')
                  }
                }
              }
            }
          }

          parallel jobs
        }
      }
    }

    stage('Release and publish') {
      when {
        branch "main"
        not { buildingTag() }
        expression { modules.size() > 0 }
      }
      environment {
        DEBUG = '*'
        HOME = '/home/jenkins'
      }
      steps {
        container('node') {
          git branch: env.GIT_BRANCH, url: "https://${env.GH_TOKEN}@github.com/${env.ORGANIZATION_NAME}/terraform-modules.git"
          sh("LERNA_ROOT_PATH=${env.WORKSPACE} npx lerna version --yes")
        }
      }
    }
  }

  post {
    always {
      summaryDuration()
    }
  }
}
