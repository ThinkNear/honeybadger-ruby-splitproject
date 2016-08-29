#!groovy

node {
    currentBuild.result = 'SUCCESS'
    try {
        stage 'Checkout'
        deleteDir()
        checkout scm

        stage 'Test'
        sh """
        #!/bin/bash -l
        rvm use .
        bundle install
        bundle exec rspec spec
        """

        stage 'Build'
        sh 'gem build *.gemspec'

        stage 'Publish'
        def buildInfo = uploadGem()

        stage 'Promote'
        promoteGem(buildInfo)

        stage 'Notify'
        emailDefault('software@thinknear.com')

    } catcr (err) {
        currentBuild.result = 'FAILURE'
        println(err.toString());
        println(err.getMessage());
        println(err.getStackTrace());
        emailDefault('software@thinknear.com')
    }
}

